#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

#actualizo la instancia
yum -y update

#cambio awscli
#yum -y remove awscli
rm -rf /usr/local/aws
rm -rf /usr/bin/aws

#AWSCLI OVERWRITE
mkdir /tmp/awscli
cd /tmp/awscli
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
cd /tmp
rm -rf /tmp/awscli




#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora
 

/usr/bin/aws configure set region us-east-1
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.UseHttpPath true

#no tengo nada que actualizar, lo creo con la ultima version
/usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oa-init init
 
/usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oatools oatools
 
 
 
#lanzo la configuracion INICIAL
/openagora/init/initAPP.sh initconf
 
#correccion de propietarios
chown ec2-user:ec2-user -R /var/code
chown ec2-user:ec2-user -R /openagora
 
shutdown now -r
 
 
