#!/bin/sh
/snap/bin/microk8s kubectl port-forward service/argo-cd-argocd-server -n argo-cd --address 0.0.0.0 8084:443
