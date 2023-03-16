#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

# INICIO AMI

sudo apt-get update
sudo apt-get -y install s3fs jq
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

#sudo groupmod --new-name ec2-user bitnami-admins
#sudo usermod -l ec2-user bitnami



#sudo mkdir -p /mnt/s3fs
#sudo chown ec2-user:ec2-user /mnt/s3fs 

# FIN AMI


#Ami no tiene /var/code
mkdir -p /var/code


#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora


