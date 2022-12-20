#!/bin/sh
/snap/bin/microk8s kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus --address 0.0.0.0 9090:9090
