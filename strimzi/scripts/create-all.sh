#!/bin/sh

# Create Namespace
kubectl apply -f strimzi/kafka/kafka-namespace.yaml
kubectl config set-context --current --namespace=kafka

# Create Kafka
kubectl apply -f strimzi/strimzi-0.28.0/install/cluster-operator/
sleep 10
kubectl apply -f strimzi/kafka/kafka-ephemeral.yaml
sleep 10
kubectl wait kafka/kafka-ephemeral --for=condition=Ready --timeout=900s

# Create Prometheus
kubectl apply -f strimzi/strimzi-0.28.0/examples/metrics/prometheus-additional-properties/prometheus-additional.yaml
sleep 5
kubectl apply -f strimzi/prometheus/prometheus-operator-deployment.yaml
sleep 5
kubectl apply -f strimzi/prometheus/strimzi-pod-monitor.yaml
sleep 5
kubectl apply -f strimzi/prometheus/prometheus-rules.yaml
sleep 5
kubectl apply -f strimzi/prometheus/prometheus.yaml
sleep 5

# Create Grafana
kubectl apply -f strimzi/grafana/grafana-load-balancer.yaml
sleep 5
kubectl get service
