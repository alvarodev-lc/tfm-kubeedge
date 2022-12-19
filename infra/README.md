# infrastructure

This folder contains yaml files to deploy services directly into the kubernetes cluster.

These files are used on a KubeEdge cluster and therefore asume worker nodes have agent,edge taints. It also asumes that the hostname of the cloudcore agent is cloudcore, if not, you can change it yourself on the yaml files.

## Notes

ArgoCD metrics need prometheus stack to be deployed BEFORE. If not, it will result in a crash on deploy. If you do not want to deploy prometheus stack, you can remove the metrics component from argocd.yaml
