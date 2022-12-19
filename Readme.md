# Content

Repository for GitOps Implementation with Kubeedge

The minimal tools required for creating a development environment for testing GitOps implementation in a k8s environment.

- **Kubernetes Cluster**, MicroK8s has been used for such purpouse.
- **Helm**, for installing required tools in the cluster not included in microk8s
- **ArgoCD**, as CD tool

## References

- [**microk8s**](https://microk8s.io/)
- [**Helm**](https://helm.sh/)
- [**ArgoCD**](https://argo-cd.readthedocs.io/en/stable/)

Development environment used to create the Kubernetes cluster:

- Cloud node: Ubuntu 22.04 LTS (amd64)
- Worker nodes: Ubuntu 22.04 LTS (arm64)

## Environment installation

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

Create personal access token as explainer [here](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) and use it as a secret on CI/CD to be able to push to another repo (For the CI yaml file).
