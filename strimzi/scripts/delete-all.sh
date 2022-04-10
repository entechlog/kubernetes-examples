#!/bin/sh

# Delete Grafana
kubectl delete --ignore-not-found=true -f strimzi/grafana/grafana-load-balancer.yaml
sleep 1

# Delete Prometheus
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus.yaml
sleep 1
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus-rules.yaml
sleep 1
kubectl delete --ignore-not-found=true -f strimzi/prometheus/strimzi-pod-monitor.yaml
sleep 1
kubectl delete --ignore-not-found=true -f strimzi/prometheus/prometheus-operator-deployment.yaml
sleep 1
kubectl delete --ignore-not-found=true -f strimzi/strimzi-0.28.0/examples/metrics/prometheus-additional-properties/prometheus-additional.yaml
sleep 1

# Delete Kafka
kubectl delete --ignore-not-found=true -f strimzi/kafka/kafka-ephemeral.yaml
sleep 1
kubectl delete --ignore-not-found=true -f strimzi/strimzi-0.28.0/install/cluster-operator/
sleep 1

# Delete Namespace
kubectl delete all --all 
sleep 1

kubectl delete --ignore-not-found=true -f strimzi/kafka/kafka-namespace.yaml
sleep 5
