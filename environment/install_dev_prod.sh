#!/bin/sh

########################################################
# 1. Setup DEV. UCP + DTR
########################################################
sudo hostnamectl set-hostname dev

DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com
DEV_IP=52.58.172.7
PRIVATE_IP=172.31.20.37

sudo docker image pull docker/ucp:3.0.4

# Install UCP
sudo docker container run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:3.0.4 install \
  --host-address $PRIVATE_IP \
  --admin-username admin \
  --admin-password adminadmin \
  --san $DEV_FQDN \
  --san $DEV_IP

# Install DTR

DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com

sudo docker container run -it --rm docker/dtr:2.5.3 install \
    --ucp-node dev \
    --ucp-username admin \
    --ucp-password adminadmin \
    --ucp-url https://${DEV_FQDN} \
    --ucp-insecure-tls \
    --replica-https-port 4443 \
    --replica-http-port 81 \
    --dtr-external-url https://${DEV_FQDN}:4443

########################################################
# 2. Setup PROD. UCP + DTR
########################################################
sudo hostnamectl set-hostname prod

PROD_FQDN=ec2-18-185-71-175.eu-central-1.compute.amazonaws.com
PROD_IP=18.185.71.175 
PRIVATE_IP=172.31.19.27

sudo docker image pull docker/ucp:3.0.4

# Install UCP
sudo docker container run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:3.0.4 install \
  --host-address $PRIVATE_IP \
  --admin-username admin \
  --admin-password adminadmin \
  --san $PROD_FQDN \
  --san $PROD_IP

# Install DTR
PROD_FQDN=ec2-18-185-71-175.eu-central-1.compute.amazonaws.com

sudo docker container run -it --rm docker/dtr:2.5.3 install \
    --ucp-node prod \
    --ucp-username admin \
    --ucp-password adminadmin \
    --ucp-url https://${PROD_FQDN} \
    --ucp-insecure-tls \
    --replica-https-port 4443 \
    --replica-http-port 81 \
    --dtr-external-url https://${PROD_FQDN}:4443


########################################################
# 3. Setup CI worker nodes for DEV and PROD
########################################################

# Setup two CI workers worker nodes, name them
# dev-ci-worker and prod-ci-worker.

# Join both the respective cluster.
# Set hostnames
sudo hostnamectl set-hostname dev-ci-worker
sudo hostnamectl set-hostname prod-ci-worker


###############################################################
# 4. Clone the application project into the current directory
###############################################################

# Loginto dev machine: sudo yum -y install git
git clone https://github.com/docker-training/dops-final-project


###############################################################
# 5. Integrate UCP and DTR
###############################################################

### DEV
export DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com
sudo curl -k https://${DEV_FQDN}:4443/ca \
    -o /etc/pki/ca-trust/source/anchors/${DEV_FQDN}:4443.crt
sudo curl -k https://${DEV_FQDN}:443/ca \
    -o /etc/pki/ca-trust/source/anchors/${DEV_FQDN}:443.crt
cat /etc/pki/ca-trust/source/anchors/${DEV_FQDN}:4443.crt
cat /etc/pki/ca-trust/source/anchors/${DEV_FQDN}:443.crt
sudo update-ca-trust
sudo /bin/systemctl restart docker.service
sudo systemctl status docker.service
# Make sure you wait a few seconds...
docker login ${DEV_FQDN}:4443

### PROD
export PROD_FQDN=ec2-18-185-71-175.eu-central-1.compute.amazonaws.com
sudo curl -k https://${PROD_FQDN}:4443/ca \
    -o /etc/pki/ca-trust/source/anchors/${PROD_FQDN}:4443.crt
sudo curl -k https://${PROD_FQDN}:443/ca \
    -o /etc/pki/ca-trust/source/anchors/${PROD_FQDN}:443.crt
sudo update-ca-trust
sudo /bin/systemctl restart docker.service
# Make sure you wait a few seconds...
docker login ${PROD_FQDN}:4443

# 
# Test push
#

# First create a admin/nginx repo in both dev and prod dtr.

# DEV. ssh to dev
export DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com
sudo docker login -u admin -p adminadmin ${DEV_FQDN}:4443

sudo docker pull nginx:latest
sudo docker tag nginx:latest ${DEV_FQDN}:4443/admin/nginx:latest
sudo docker push ${DEV_FQDN}:4443/admin/nginx:latest

# PROD. ssh to prod.
export PROD_FQDN=ec2-18-185-71-175.eu-central-1.compute.amazonaws.com
sudo docker login -u admin -p adminadmin ${PROD_FQDN}:4443

sudo docker pull nginx:latest
sudo docker tag nginx:latest ${PROD_FQDN}:4443/admin/nginx:latest
sudo docker push ${PROD_FQDN}:4443/admin/nginx:latest

##
## Build jenkins server and push to DTR of DEV
##

sudo docker run -it --user=root --entrypoint=/bin/sh jenkins:2.60.3

# Loginto dev machine: sudo yum -y install git
git clone https://github.com/docker-training/dops-final-project
