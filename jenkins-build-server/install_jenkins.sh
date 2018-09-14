#!/bin/sh
apt-get update -y
apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce 
rm -rf /var/lib/apt/lists/*
echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
