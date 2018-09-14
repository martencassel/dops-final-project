#!/bin/sh

################################################
# Upload jenkins to DEV DTR
################################################

# 1. Create repo admin/my-jenkins:1.0
# 2. Build 
DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com

docker image build -t ${DEV_FQDN}:4443/admin/my-jenkins:1.0 .

# 3. Push image
docker image push ${DTR_FQDN}:4443/admin/my-jenkins:1.0