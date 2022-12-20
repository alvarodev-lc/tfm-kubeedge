#!/bin/sh
/snap/bin/microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard --address 0.0.0.0 8080:443
