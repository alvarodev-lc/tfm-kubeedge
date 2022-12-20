# Content

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

## KubeEdge

References:

- [**Keadm getting started**](https://kubeedge.io/en/docs/setup/keadm/)
- [**Keadm releases**](https://github.com/kubeedge/kubeedge/releases)

Install KubeEdge (amd64). I will be using version 1.9.2, please check the [compatibility matrix](https://github.com/kubeedge/kubeedge#kubernetes-compatibility) before installing a specific version.

```sh
wget https://github.com/kubeedge/kubeedge/releases/download/v1.9.2/keadm-v1.9.2-linux-amd64.tar.gz
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

## Edge

## ArgoCD RBAC

TODO

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
