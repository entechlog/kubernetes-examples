# Dockerfile
FROM python:3.9-slim-buster

WORKDIR /usr/app

# Install Linux Packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    sshpass \
    openssh-server \ 
    sudo \
    nmap \
    apt-transport-https \
    ca-certificates && \
    apt-get purge -y --auto-remove

# Install kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN sudo apt-get update
RUN sudo apt-get install -y kubectl

# Install Python packages
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Create ubuntu user 
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu 
USER ubuntu
WORKDIR /home/ubuntu

CMD ["ansible", "--version"]