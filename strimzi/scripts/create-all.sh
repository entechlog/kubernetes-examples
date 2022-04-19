#!/bin/sh

# Create Namespace
kubectl apply -f strimzi/kafka/kafka-namespace.yaml
kubectl config set-context --current --namespace=kafka

# Create Kafka
sed -i 's/namespace: .*/namespace: kafka/' strimzi/strimzi-0.28.0/install/cluster-operator/*RoleBinding*.yaml
kubectl apply -f strimzi/strimzi-0.28.0/install/cluster-operator/
sleep 10

kubectl apply -f strimzi/kafka/kafka-clusterrolebindings.yaml
sleep 10

kubectl wait --for condition=established --timeout=300s crd/kafkas.kafka.strimzi.io

kubectl apply -f strimzi/kafka/kafka-ephemeral.yaml
sleep 10

kubectl wait kafka/kafka-ephemeral --for=condition=Ready --timeout=900s

# Create Prometheus
curl -s \
https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.50/bundle.yaml \
| sed -e 's/namespace: default/namespace: kafka/' > strimzi/prometheus/prometheus-operator-deployment.yaml
kubectl apply -f strimzi/prometheus/prometheus-operator-deployment.yaml
sleep 5

cp strimzi/strimzi-0.28.0/examples/metrics/prometheus-additional-properties/prometheus-additional.yaml \
strimzi/prometheus/prometheus-additional.yaml
kubectl apply -f strimzi/prometheus/prometheus-additional.yaml
sleep 5

cat strimzi/strimzi-0.28.0/examples/metrics/prometheus-install/strimzi-pod-monitor.yaml \
| sed -e 's/- myproject/- kafka/' > strimzi/prometheus/strimzi-pod-monitor.yaml
kubectl apply -f strimzi/prometheus/strimzi-pod-monitor.yaml
sleep 5

cp strimzi/strimzi-0.28.0/examples/metrics/prometheus-install/prometheus-rules.yaml \
strimzi/prometheus/prometheus-rules.yaml
kubectl apply -f strimzi/prometheus/prometheus-rules.yaml
sleep 5

cat strimzi/strimzi-0.28.0/examples/metrics/prometheus-install/prometheus.yaml \
| sed -e 's/namespace: myproject/namespace: kafka/' > strimzi/prometheus/prometheus.yaml
kubectl apply -f strimzi/prometheus/prometheus.yaml
sleep 5

# Create Grafana
kubectl apply -f strimzi/grafana/grafana-load-balancer.yaml
sleep 5
kubectl get service
