#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

# INICIO AMI

sudo apt-get update
sudo apt-get -y install s3fs jq rsync
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

sudo groupmod --new-name ec2-user bitnami-admins
sudo usermod -l ec2-user bitnami
usermod -aG sudo ec2-user


sudo mkdir -p /mnt/s3fs
sudo chown ec2-user:ec2-user /mnt/s3fs 


sudo mkdir -p /openagora
sudo chown ec2-user:ec2-user /openagora/

#calculo el ROL de la INSTANCIA
IAMROLE=$(curl http://169.254.169.254/latest/meta-data/iam/info -s | jq .InstanceProfileArn | xargs basename)

#montaje manual:
#s3fs oadeploy -o iam_role=${IAMROLE} -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp /mnt/s3fs

#montaje por FSTAB:
echo "s3fs#oadeploy /mnt/s3fs fuse _netdev,allow_other,iam_role=${IAMROLE},use_cache=/tmp,url=https://s3.us-east-1.amazonaws.com 0 0" |  tee -a /etc/fstab
mount /mnt/s3fs
# FIN AMI


#Ami no tiene /var/code
mkdir -p /var/code


#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora


