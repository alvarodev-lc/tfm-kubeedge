# Infrastructure

This folder contains yaml files to deploy services directly into the kubernetes cluster.

These files are used on a KubeEdge cluster and therefore asume worker nodes have agent,edge taints. It also asumes that the hostname of the cloudcore agent is cloudcore, if not, you can change it yourself on the yaml files.

Please note that you should replace the --values flag path to the path where your values.yaml files are located.

## Install Helm

```sh
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## ArgoCD

ArgoCD metrics need prometheus stack to be deployed BEFORE. If not, it will result in a crash on deploy. If you do not want to deploy prometheus stack, you can remove the metrics component from argocd.yaml

Get Helm repository

```sh
helm repo add argo https://argoproj.github.io/argo-helm
```

Update Helm repositories

```sh
helm repo update
```

Install ArgoCD version 4.3.1 using Helm

```sh
helm install argo-cd --create-namespace --namespace argo-cd --values values.yaml --version 4.3.1 argo/argo-cd
```

To access the web interface, you need to forward the service port to the port you want to use

```sh
kubectl port-forward service/argo-cd-argocd-server -n argo-cd <PORT>:443
```

To access for the first time, use **admin** as the user, and get the password using the following command in the cloud

```sh
kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### [ArgoCD RBAC](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/)

The ArgoCD RBAC lets you create new users and restrict permissions to specific resources.

First install the ArgoCD CLI

```sh
wget https://github.com/argoproj/argo-cd/releases/download/v2.5.0/argocd-linux-amd64
```

Make it executable

```sh
chmod +x argocd-linux-amd64
```

Change the name to argocd for simplicity

```sh
mv argocd-linux-amd64 argocd
```

Move the executable to **usr/local/bin** to make it executable on the global context

```sh
sudo mv argocd /usr/local/bin
```

Now you can execute argocd commands, but first you have to log in to the argocd server

```sh
argocd login <IP>:<ServerPort>
```

To create a new user

```sh
kubectl edit configmap argocd-cm -n <ArgoCD Namespace>
```

Add a new user to the configmap like in this example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: argocd-cm
    namespace: argocd
    labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
    # add an additional local user with apiKey and login capabilities
    #   apiKey - allows generating API keys
    #   login - allows to login using UI
    accounts.<USERNAME>: apiKey, login
```

Update it's password

```sh
argocd account update-password --account <USERNAME>
```

It's recommended to disable admin account afterwards, for security reasons. Add admin.enabled: "false"

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: argocd-cm
    namespace: argocd
    labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
    # add an additional local user with apiKey and login capabilities
    #   apiKey - allows generating API keys
    #   login - allows to login using UI
    accounts.<USERNAME>: apiKey, login
    admin.enabled: "false"
```

To give new users permissions, we need to create a new group, asign it to the user, and give permissions to the group in the rbac configmap

```sh
kubectl edit configmap argocd-rbac-cm -n <ArgoCD Namespace>
```

Example configurationm giving the user all permissions for repositories and applications only

```yaml
apiVersion: v1
data:
  policy.csv: |
    p, role:etsisi, applications, *, */*, allow
    p, role:etsisi, repositories, *, */*, allow

    g, alvaro, role:etsisi
  policy.default: role:readonly
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: argo-cd
    meta.helm.sh/release-namespace: argo-cd
  creationTimestamp: "2022-10-11T16:31:26Z"
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argo-cd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
    helm.sh/chart: argo-cd-4.3.1
  name: argocd-rbac-cm
  namespace: argo-cd
  resourceVersion: "333628"
  selfLink: /api/v1/namespaces/argo-cd/configmaps/argocd-rbac-cm
  uid: 7ef1abaa-247f-411f-9552-cdd4640ff82e
```

After that, you can access ArgoCD in the web interface using your new user

## Prometheus Stack

In prometheus-stack.yaml set additionalScrapeConfigs using your internal IP addresses and hostnames, or just delete if you are not going to use custom endpoints for metrics. This one is set to use the [metrics server](https://github.com/kubernetes-sigs/metrics-server).

Get the Helm repository

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update Helm repositories

```sh
helm repo update
```

Install Prometheus Stack version 35.0.3 using Helm

```sh
helm install prometheus --create-namespace --namespace monitoring --values /home/alvaro/infra/prometheus.yaml prometheus-community/kube-prometheus-stack --version 35.0.3
```

## Metrics Server

Deploys metric server on the Cloud. To deploy metric server components on the Edge nodes and get further information, please check the metrics server PDF file in this folder.

```sh
kubectl apply -f metrics-server.yaml
```
