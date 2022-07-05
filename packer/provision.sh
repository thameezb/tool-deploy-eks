#!/bin/sh
set -e

mkdir -p /usr/local/share/ca-certificates
sudo curl --insecure 'https://ataboymirror-agct.gray.net/reliable_deployments/ssl_certs/rootSHA256.cer' --output '/usr/local/share/ca-certificates/rootSHA256.crt'
sudo curl --insecure 'https://ataboymirror-agct.gray.net/reliable_deployments/ssl_certs/issuingca1SHA256.cer' --output '/usr/local/share/ca-certificates/issuingca1SHA256.crt'
sudo curl --insecure 'https://ataboymirror-agct.gray.net/reliable_deployments/ssl_certs/issuingca2SHA256.cer' --output '/usr/local/share/ca-certificates/issuingca2SHA256.crt'
sudo update-ca-certificates

sudo apt-get -y install awscli

sudo apt-get -y autoremove
sudo apt-get -y clean
