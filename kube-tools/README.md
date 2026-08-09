- [Overview](#overview)
- [Instructions](#instructions)
  - [kube-tools](#kube-tools)
  - [Octant](#octant)
  - [Scope](#scope)
  - [k9s](#k9s)
  - [Lens](#lens)

# Overview
The kube-tools container bundles software like kubectl, helm, and octant to help work with a Kubernetes cluster.

# Instructions

## kube-tools
- Bring up the kube-tools container by running
  ```bash
  docker compose up -d --build
  ```
- Tear down the kube-tools container by running
  ```bash
  docker compose down -v --remove-orphans
  ```

## Octant
> **Note:** Octant was archived by VMware in January 2023 and is no longer maintained. It still runs, but treat it as a frozen legacy tool rather than something to rely on long-term.

- Make sure to copy the config file of your kubernetes cluster into `./.kube/config`. This is a prerequisite to start the octant service, which is why it's kept in its own docker-compose file
- Bring up the container by running
  ```bash
  docker compose -f docker-compose-octant.yml up -d --build
  ```
- Navigate to http://localhost:7777/ to access the octant UI
- Tear down the container by running
  ```bash
  docker compose -f docker-compose-octant.yml down -v --remove-orphans
  ```

## Scope
> **Note:** Weave Scope is no longer maintained following Weaveworks' shutdown in early 2024. It still runs, but expect no further updates or security fixes.

- Bring up the container by running
  ```bash
  docker compose -f docker-compose-scope.yml up -d
  ```
- Navigate to http://localhost:4040/ to access the scope UI
- Tear down the container by running
  ```bash
  docker compose -f docker-compose-scope.yml down -v --remove-orphans
  ```

## k9s
- Make sure to copy the config file of your kubernetes cluster into `./.kube/config`.
- Bring up the container by running
  ```bash
  docker compose -f docker-compose-k9s.yml up -d --build
  ```
- SSH into the container
  ```bash
  docker exec -it k9s /bin/bash
  ```
- Enter the k9s CLI by running
  ```bash
  k9s
  ```
- Tear down the container by running
  ```bash
  docker compose -f docker-compose-k9s.yml down -v --remove-orphans
  ```

## Lens
> **Note:** Lens is now a commercial product under Mirantis, requiring a subscription for most business use, and OpenLens (the open-source fork this section originally pointed to) is no longer maintained. [FreeLens](https://freelens.app/) is the current community-maintained, genuinely free fork.

[Lens](https://k8slens.dev/) is a desktop application only, so download and install it (or [FreeLens](https://freelens.app/)) for your OS.
