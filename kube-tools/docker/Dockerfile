# Dockerfile
FROM python:3.13-slim-trixie

WORKDIR /usr/app

# Install Linux Packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    snapd \
    git \
    curl \
    sshpass \
    openssh-server \
    sudo \
    nmap \
    gnupg \
    apt-transport-https \
    ca-certificates && \
    apt-get purge -y --auto-remove

# Install kubectl (legacy apt.kubernetes.io repo was deprecated in favor of pkgs.k8s.io)
RUN sudo mkdir -p /etc/apt/keyrings
RUN sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN sudo apt-get update
RUN sudo apt-get install -y kubectl

# Install helm (official install script replaces the deprecated apt-key based repo)
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Get version from env
ARG OCTANT_VERSION
ARG K9S_VERSION

# Install octant
RUN wget https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.deb
RUN dpkg -i octant_${OCTANT_VERSION}_Linux-64bit.deb

# Install k9s
RUN sudo wget -qO- https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz | tar zxvf -  -C /tmp/
RUN sudo mv /tmp/k9s /usr/local/bin

# Install Python packages
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Create ubuntu user 
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu 
USER ubuntu
WORKDIR /home/ubuntu

CMD ["ansible", "--version"]