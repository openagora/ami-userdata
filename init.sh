#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

#actualizo la instancia
yum -y update --exclude=python*


#Julio2021
# awscli fue instalado usando pip de python3 para poder tener awscli 2.x



#Ami no tiene /var/code
mkdir -p /var/code

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
 
 
#Borro el bash_history
cat /dev/null > ~/.bash_history && history -c
rm -rf /home/ec2-user/.bash_history
  
 
#EOF
shutdown now -r



