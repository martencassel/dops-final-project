DEV_FQDN=ec2-52-58-172-7.eu-central-1.compute.amazonaws.com

openssl s_client -connect ${DEV_FQDN}:443 -showcerts \
</dev/null 2>/dev/null | openssl x509 -outform PEM | sudo tee \ /usr/local/share/ca-certificates/${DEV_FQDN}.crt
sudo update-ca-certificates
/bin/tini -- /usr/local/bin/jenkins.sh