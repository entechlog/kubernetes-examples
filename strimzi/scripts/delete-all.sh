#!/bin/sh

# Delete Grafana
kubectl delete --ignore-not-found=true -f strimzi/grafana/grafana.yaml

# Delete Prometheus
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus.yaml
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus-rules.yaml
kubectl delete --ignore-not-found=true -f strimzi/prometheus/strimzi-pod-monitor.yaml
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus-operator-deployment.yaml
kubectl delete --ignore-not-found=true -f strimzi/strimzi-0.28.0/examples/metrics/prometheus-additional-properties/prometheus-additional.yaml

# Delete Kafka
kubectl delete --ignore-not-found=true -f strimzi/kafka/kafka-ephemeral.yaml
kubectl delete --ignore-not-found=true -f strimzi/strimzi-0.28.0/install/cluster-operator/

# Delete Namespace
kubectl delete all --all 
kubectl delete --ignore-not-found=true -f strimzi/kafka/kafka-namespace.yaml
