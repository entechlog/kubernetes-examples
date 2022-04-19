- [Overview](#overview)
- [Instructions](#instructions)
  - [kube-tools](#kube-tools)
  - [Octant](#octant)
  - [Scope](#scope)
  - [k9s](#k9s)
  - [Lens](#lens)
  
# Overview
kube tools container contains contains software's like kubectl, helm, octant which helps to work with a kubernetes cluster.

# Instructions

## kube-tools
- Bring up the kube-tools container by running
  ```bash
  docker-compose up -d --build
  ```
- Bring up the kube-tools container by running
  ```bash
  docker-compose down -v --remove-orphans
  ```

## Octant
- Make sure to copy the config file of your kubernetes cluster into `./.kube/config`. config is a prerequisite to start octant service. Only for that reason octant service is maintained in its own docker-compose file
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-octant.yml up -d --build
  ```
- Navigate to http://localhost:7777/ to access the octant UI
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-octant.yml down -v --remove-orphans
  ```

## Scope
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-scope.yml up -d
  ```
- Navigate to http://localhost:4040/ to access the scope UI
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-scope.yml down -v --remove-orphans
  ```

## k9s
- Make sure to copy the config file of your kubernetes cluster into `./.kube/config`.
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-k9s.yml up -d --build
  ```
- SSH into the container
  ```bash
  docker exec -it k9s /bin/bash
  ```
- Enter into k9s CLI by running 
  ```bash
  k9s
  ```
- Bring up the container by running
  ```bash
  docker-compose -f docker-compose-k9s.yml down -v --remove-orphans
  ```

## Lens 
[Lens] https://k8slens.dev/ is currently a desktop application only. So download and install Lens Desktop for your OS