# Dockerfile
FROM python:3.9-slim-buster

WORKDIR /usr/app

# Install Linux Packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
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

# Install kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN sudo apt-get update
RUN sudo apt-get install -y kubectl

# Install helm
RUN curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN sudo apt-get update
RUN sudo apt-get install helm

# Install 
RUN wget https://github.com/vmware-tanzu/octant/releases/download/v0.25.1/octant_0.25.1_Linux-64bit.deb
RUN dpkg -i octant_0.25.1_Linux-64bit.deb

# Install Python packages
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Create ubuntu user 
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu 
USER ubuntu
WORKDIR /home/ubuntu

CMD ["ansible", "--version"]