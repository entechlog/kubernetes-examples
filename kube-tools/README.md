- [Overview](#overview)
- [Instructions](#instructions)
  - [kube-tools](#kube-tools)
  - [octant](#octant)
  
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

## octant
- Make sure to copy the config file of your kubernetes cluster into `./.kube/config`. config is a prerequisite to start octant service. Only for that reason octant service is maintained in its own docker-compose file
- Bring up the octant container by running
  ```bash
  docker-compose up -f docker-compose-octant.yml -d --build
  ```
- Bring up the octant container by running
  ```bash
  docker-compose -f docker-compose-octant.yml down -v --remove-orphans
  ```
- Navigate to http://localhost:7777/ to access the octant UI