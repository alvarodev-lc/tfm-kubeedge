#!/bin/sh
/snap/bin/microk8s kubectl port-forward -n monitoring service/prometheus-grafana --address 0.0.0.0 3000:80
