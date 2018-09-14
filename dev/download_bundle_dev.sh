[ec2-user@dev ~]$ cat download_bundle_dev.sh
#!/bin/sh

UCP_IP=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com

AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"adminadmin"}' \
	 https://${UCP_IP}/auth/login | jq -r .auth_token)

cd ucp-bundle-admin
curl -k -H "Authorization: Bearer $AUTHTOKEN" \
    https://${UCP_IP}/api/clientbundle -o bundle.zip
unzip bundle.zip

source ./ucp-bundle-admin/env.sh

sudo docker node ls