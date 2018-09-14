#!/bin/sh

sudo docker node update --label-add jenkins=master dev-ci-worker

export DTR_IP=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com
export DTR_FQDN=$DTR_IP

sudo docker service rm my-jenkins

sudo docker service create --name my-jenkins --publish 8080:8080 \
         --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
         --mount type=bind,source=/home/ec2-user/jenkins,destination=/var/jenkins_home \
         --mount \
         type=bind,source=/home/ec2-user/ucp-bundle-admin,destination=/home/jenkins/ucp-bundle-admin \
         --constraint 'node.labels.jenkins == master' \
         --detach=false \
         -e DTR_IP=${DTR_IP} \
         ${DTR_FQDN}:4443/admin/my-jenkins:1.0