- [Overview](#overview)
- [Instructions](#instructions)
  
# Overview
Quick run down on how to start kafka-lag-exporter in Kubernetes

# Instructions

- Add the chart repository for kafka-lag-exporter
  
  ```bash
  helm repo add kafka-lag-exporter https://seglo.github.io/kafka-lag-exporter/repo/
  ```

- Update information of available charts locally from chart repositories
  
  ```bash
  helm repo update
  ```

- List and verify the chart repository

  ```bash
  helm repo list
  ```

- Create values.yml file based on your use case, See [here](https://github.com/seglo/kafka-lag-exporter/blob/master/charts/kafka-lag-exporter/values.yaml) for a sample file with detailed explanation for each of the configuration. You can change service type in this as well
  
- Do a dry run install to verify the generated yaml file from the values file
  
  ```bash
  helm install kafka-lag-exporter \
  kafka-lag-exporter/kafka-lag-exporter \
  --namespace kafka --dry-run --debug \
  -f kafka-lag-exporter/lag-exporter-values.yml
  ```
- Do actual install by running below command
  
  ```bash
  helm install kafka-lag-exporter \
  kafka-lag-exporter/kafka-lag-exporter \
  --namespace kafka \
  -f kafka-lag-exporter/lag-exporter-values.yml
  ```

- If you used `ClusterIP` you can access the metric endpoint following below steps
  
  ```bash
  kubectl port-forward service/kafka-lag-exporter-service 8000:8000 --namespace kafka
  # Navigate to below endpoint in your browser
  http://127.0.0.1:8000
  ```

- If you used `NodePort` you can access the metric endpoint following below steps
  
  ```bash
  export NODE_PORT=$(kubectl get --namespace kafka -o jsonpath="{.spec.ports[0].nodePort}" services kafka-lag-exporter-service)
  export NODE_IP=$(kubectl get nodes --namespace kafka -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
  # Navigate to the endpoint from above echo 
  # If you use Kubernetes in Docker then use localhost:NODEPORT to access the endpoint like `http://localhost:30072/`
  ```

- If the endpoint is operational you can add it to Prometheus target. If you don't have a Prometheus target for demo create one quickly by running below docker-compose from [kafka-examples](https://github.com/entechlog/kafka-examples/tree/master/kafka-consumer-lag)
  
  ```bash
  docker-compose -f docker-compose-kafka-lag-exporter-kube.yaml up -d --build
  ```
  