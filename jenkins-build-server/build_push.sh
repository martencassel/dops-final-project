#!/bin/sh

# Loginto dev machine.
# Install git: [ec2-user@dev ~]$ sudo yum -y install git

chmod +x ./entrypoint.sh

DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com

sudo curl -k https://${DEV_FQDN}:4443/ca > dtr_ca.pem
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain dtr_ca.pem
sudo curl -k https://${DEV_FQDN}:443/ca > ucp_ca.pem
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ucp_ca.pem

DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com
sudo docker login -u admin -p adminadmin ${DEV_FQDN}:4443
sudo docker image build -t ${DEV_FQDN}:4443/admin/my-jenkins:1.0 .

sudo docker image push ${DEV_FQDN}:4443/admin/my-jenkins:1.0

sudo docker run -it --user=root \
    --entrypoint=/bin/sh \
     -v /var/run/docker.sock:/var/run/docker.sock \
    ${DEV_FQDN}:4443/admin/my-jenkins:1.0
