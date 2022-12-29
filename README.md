# Alvaro Lopez - Masters Project

Repository for GitOps Implementation with Kubeedge

The minimal tools required for creating a development environment for testing GitOps implementation in a k8s environment.

- **Kubernetes Cluster**, MicroK8s has been used for such purpouse.
- **Helm**, for installing required tools in the cluster not included in microk8s
- **ArgoCD**, as CD tool

## References

- [**Microk8s**](https://microk8s.io/)
- [**Helm**](https://helm.sh/)
- [**ArgoCD**](https://argo-cd.readthedocs.io/en/stable/)

Development environment used to create the Kubernetes cluster:

- Cloud node: Ubuntu 22.04 LTS (amd64)
- Worker nodes: Ubuntu 22.04 LTS (arm64)

## Environment installation (Ubuntu 22.04 LTS)

## Cloud

## Microk8s

Microk8s should be installed on the cloud node only. [Snap](https://snapcraft.io/docs) can be used for this matter

```sh
sudo apt update
sudo apt install snapd
```

Install kubectl to interact with the cluster

```sh
sudo snap install kubectl --classic
```

List available microk8s versions

```sh
sudo snap info microk8s
```

Install the desired version, for this demo I used 1.22

```sh
sudo snap install microk8s --classic --channel=1.22/stable
```

Disable high availability cluster feature, to avoid Kubernetes trying to deploy calico to our edge nodes

```sh
microk8s disable ha-cluster
```

Enable basic services

```sh
microk8s enable dns dashboard storage
```

After a little bit of time, microk8s should deploy the services, you can check using

```sh
microk8s status
```

To interact with the Kubernetes cluster without having to use microk8s command, it is needed to generate a config file from microk8s

```sh
microk8s config > $HOME/.kube/config
```

Confirm your cluster is up and running

```sh
kubectl cluster-info
```

To access the Kubernetes dashboard, forward the service port to the port you want to use

```sh
kubectl port-forward -n kube-system service/kubernetes-dashboard 8080:443
```

## KubeEdge

References:

- [**Keadm getting started**](https://kubeedge.io/en/docs/setup/keadm/)
- [**Keadm releases**](https://github.com/kubeedge/kubeedge/releases)

Install KubeEdge. In this case we will install amd64 version on the cloud and arm64 on the edge nodes since I am using Raspberry Pi's. I will be using version 1.9.2, please check the [compatibility matrix](https://github.com/kubeedge/kubeedge#kubernetes-compatibility) before installing a specific version.

For amd64

```sh
wget https://github.com/kubeedge/kubeedge/releases/download/v1.9.2/keadm-v1.9.2-linux-amd64.tar.gz
```

For arm64

```sh
wget https://github.com/kubeedge/kubeedge/releases/download/v1.9.2/keadm-v1.9.2-linux-arm64.tar.gz 
```

Extract contents and move **keadm** executable to **/usr/local/bin** to make keadm command executable from global context

```sh
tar -xvf keadm-v1.9.2-linux-arm64.tar.gz

sudo mv keadm-v1.9.2-linux-arm64.tar.gz /usr/local/bin/keadm

sudo chmod +x /usr/local/bin/keadm
```

Initialize the cluster. If you are using a machine from outside your local environment, please use it's public IP

```sh
keadm init --kube-config ${HOME}/.kube/config --advertise-address "KUBEDGE_CLOUDCORE_ADDRESS"
```

The Cloudcore process should be started automatically, please check logs to see if everything is running normally

```sh
sudo systemctl status cloudcore
```

or

```sh
tail -f /var/log/kubeedge/cloudcore.log
```

To reboot cloudcore

```sh
sudo systemctl restart cloudcore
```

Check your cloudcore node is up and running in the Kubernetes cluster

```sh
kubectl get nodes
```

Get KubeEdge token to join Edge nodes to the cluster

```sh
keadm gettoken --kube-config ${HOME}/.kube/config
```

## Edge

Once KubeEdge is installed following the [KubeEdge section](https://github.com/alvarodev-lc/tfm-kubeedge#kubeedge), and the token has been obtained, we can join edge nodes to the cluster

```sh
keadm join --cloudcore-ipport=KUBEDGE_CLOUDCORE_ADDRESS:10000 --edgenode-name=<NODE-NAME> --token=<TOKEN> --kubeedge-version=<Version>
```

This should automatically start the Edgecore process, and join the node to the cluster. Check logs to see if it's working as expected

```sh
sudo systemctl status edgecore
```

or

```sh
sudo journalctl -u edgecore.service -xe
```

To restart edgecore

```sh
sudo systemctl restart edgecore
```

## Troubleshooting

If you are getting cgroup errors on the edgecore, try to modify edgecore configuration under **/etc/kubeedge/config/edgecore.yaml** and set

```sh
cgroupDriver: systemd
```

After that, reboot the Edgecore process and check logs.

If edgecore can't connect to the cloud because it says a node with that hostname already exists, it probably is because you had previously joined that node and it left the cluster before, rebooting both the cloud and the edge node should be enough to fix that.

## Infrastructure

To deploy different services to the cluster we just created, please check the [infrastructure documentation](https://github.com/alvarodev-lc/tfm-kubeedge/tree/master/infra)

## Metrics

To enable metrics, first deploy the [metrics server](https://github.com/alvarodev-lc/tfm-kubeedge/tree/master/infra)

The cluster CA is required to establish communication between the cloudcore and the edgecore.

To generate the certificated needed, we will use [certgen.sh](https://github.com/rlopezv/gitops/blob/master/infra/kubeedge/certgen.sh). It should be copied to **/etc/kubeedge**

```sh
## Set working directory
cd /etc/kubeedge

# Declare vars
export CLOUDCOREIPS="<CLOUD_IP>"
export K8SCA_FILE=/var/snap/microk8s/current/certs/ca.crt
export K8SCA_KEY_FILE=/var/snap/microk8s/current/certs/ca.key

# Generate certificates
./certgen.sh -E stream
```

## Enable routing

Once these certificates are generated it's required to modify the iptables and the KubeEdge configuration files on both cloudside and edgeside.

On cloudside

Modify **/etc/kubeedge/config/cloudcore.yaml**

Enable stream

```sh
cloudStream:
  # change
  enable: true
```

```sh
iptables -t nat -A OUTPUT -p tcp --dport 10350 -j DNAT --to <CLOUD_IP>:10003
```

On edge side (every edge node)

Modify /etc/kubeedge/config/edgecore.yaml

Enable stream

```sh
edgeStream:
  # change
  enable: true
  # Check value of cloudserver
  server: [CLOUDCOREIP]:10004 
```

Restart Cloudcore and Edgecore after making the changes to the configuration

Once done, edge node metrics should be accessible from edge nodes

```sh
# On cloud side
curl -k "https://[NODE_IP]:10351/stats/summary?only_cpu_and_memory=true"
```

Example

```json
{
 "node": {
  "nodeName": "edgenode01",
  "systemContainers": [
   {
    "name": "kubelet",
    "startTime": "2022-10-22T16:17:01Z",
    "cpu": {
     "time": "2022-10-22T18:45:07Z",
     "usageNanoCores": 36490670,
     "usageCoreNanoSeconds": 252662549983
    },
    "memory": {
     "time": "2022-10-22T18:45:07Z",
     "usageBytes": 30613504,
     "workingSetBytes": 30613504,
     "rssBytes": 27066368,
     "pageFaults": 22869,
     "majorPageFaults": 0
    }
   },
   {
    "name": "runtime",
    "startTime": "2022-10-20T16:47:00Z",
    "cpu": {
     "time": "2022-10-22T18:45:13Z",
     "usageNanoCores": 13118760,
     "usageCoreNanoSeconds": 1786750198925
    },
    "memory": {
     "time": "2022-10-22T18:45:13Z",
     "usageBytes": 115150848,
     "workingSetBytes": 51351552,
     "rssBytes": 36360192,
     "pageFaults": 19054431,
     "majorPageFaults": 297
    }
   },
   {
    "name": "pods",
    "startTime": "2022-10-20T16:47:31Z",
    "cpu": {
     "time": "2022-10-22T18:45:03Z",
     "usageNanoCores": 0,
     "usageCoreNanoSeconds": 0
    },
    "memory": {
     "time": "2022-10-22T18:45:03Z",
     "availableBytes": 3977527296,
     "usageBytes": 0,
     "workingSetBytes": 0,
     "rssBytes": 0,
     "pageFaults": 0,
     "majorPageFaults": 0
    }
   }
  ],
  "startTime": "2022-10-20T16:47:01Z",
  "cpu": {
   "time": "2022-10-22T18:45:02Z",
   "usageNanoCores": 62053022,
   "usageCoreNanoSeconds": 9409379988290
  },
  "memory": {
   "time": "2022-10-22T18:45:02Z",
   "availableBytes": 2643247104,
   "usageBytes": 2401181696,
   "workingSetBytes": 1334280192,
   "rssBytes": 165142528,
   "pageFaults": 76527,
   "majorPageFaults": 165
  },
  "network": {
   "time": "2022-10-22T18:45:02Z",
   "name": "eth0",
   "rxBytes": 680926297,
   "rxErrors": 0,
   "txBytes": 43422651,
   "txErrors": 0,
   "interfaces": [
    {
     "name": "wlan0",
     "rxBytes": 0,
     "rxErrors": 0,
     "txBytes": 0,
     "txErrors": 0
    },
    {
     "name": "eth0",
     "rxBytes": 680926297,
     "rxErrors": 0,
     "txBytes": 43422651,
     "txErrors": 0
    }
   ]
  },
  "fs": {
   "time": "2022-10-22T18:45:02Z",
   "availableBytes": 22324531200,
   "capacityBytes": 31064162304,
   "usedBytes": 7425003520,
   "inodesFree": 1805511,
   "inodes": 1933312,
   "inodesUsed": 127801
  },
  "runtime": {
   "imageFs": {
    "time": "2022-10-22T18:45:02Z",
    "availableBytes": 22324531200,
    "capacityBytes": 31064162304,
    "usedBytes": 1395364102,
    "inodesFree": 1805511,
    "inodes": 1933312,
    "inodesUsed": 127801
   }
  },
  "rlimit": {
   "time": "2022-10-22T18:45:17Z",
   "maxpid": 4194304,
   "curproc": 204
  }
 },
 "pods": []
}
```

Once completed the following info should be available

```sh
$ kubectl top nodes
NAME             CPU(cores)   CPU%        MEMORY(bytes)   MEMORY%     
edgenode01       48m          1%          1272Mi          34%         
edgenode02       41m          1%          1169Mi          31%         
rpi3             97m          2%          403Mi           49%         
ubuntu-desktop   1688m        21%         9959Mi          41%         
```

## Gitlab Runner

Choose a hardware to use as gitlab-runner, could be a worker node or any other hardware.

Download the binary to your system

```sh
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-arm64
```

Give it permission to execute

```sh
sudo chmod +x /usr/local/bin/gitlab-runner
```

Create a GitLab Runner user

```sh
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
```

Install and run as a service

```sh
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
```

Add user to docker group. Required for kaniko.

```sh
sudo usermod -aG docker gitlab-runner
```

Initialize the runner

```sh
sudo gitlab-runner start
```

Verify so that it stays as active on gitlab

```sh
sudo gitlab-runner verify
```

Register the runner on gitlab. IMPORTANT!!! REGISTER AS DOCKER

```sh
sudo gitlab-runner register
```

IMPORTANT!! Edit runner on gitlab so that it runs jobs without tags if you use no tags on your CI yaml file

Create personal access token as explained [here](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) and use it as a secret on CI/CD to be able to push to another repo (For the CI yaml file).
