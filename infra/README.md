# Infrastructure

This folder contains yaml files to deploy services directly into the kubernetes cluster.

These files are used on a KubeEdge cluster and therefore asume worker nodes have agent,edge taints. It also asumes that the hostname of the cloudcore agent is cloudcore, if not, you can change it yourself on the yaml files.

## ArgoCD

ArgoCD metrics need prometheus stack to be deployed BEFORE. If not, it will result in a crash on deploy. If you do not want to deploy prometheus stack, you can remove the metrics component from argocd.yaml

# Prometheus Stack

In prometheus-stack.yaml set additionalScrapeConfigs using your internal IP addresses and hostnames, or just delete if you are not going to use custom endpoints for metrics. This one is set to use the [metrics server](https://github.com/kubernetes-sigs/metrics-server).

# Metrics Server

Deploys metric server on the Cloud. To deploy metric server components on the Edge nodes and get further information, please check the metrics server PDF file in this folder.
