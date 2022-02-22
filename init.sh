#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

#Ami no tiene /var/code
mkdir -p /var/code

#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora



if /sbin/nvme -list | /bin/grep -q "Instance Storage" ; then

mkdir -p /mnt/ephemeral0
/usr/bin/chown ec2-user:ec2-user /mnt/ephemeral0
/usr/sbin/mkfs.xfs /dev/nvme1n1
/usr/bin/mount /dev/nvme1n1 /mnt/ephemeral0/

#el working dir DEBE SER el ephemeral
mkdir -p /mnt/ephemeral0/workingdir
/usr/bin/chown ec2-user:ec2-user /mnt/ephemeral0/workingdir
ln -s  /mnt/ephemeral0/workingdir /var/code/workingdir
/usr/bin/chown -h ec2-user:ec2-user /var/code/workingdir

else

#el working dir por defecto estará en el EBS
mkdir -p /var/code/workingdir

fi


#actualizo la instancia
yum -y update --exclude=python*


#Julio2021
# awscli fue instalado usando pip de python3 para poder tener awscli 2.x


/usr/bin/aws configure set region us-east-1
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.UseHttpPath true

mkdir -p /openagora/init
/usr/bin/tar -C /openagora/init -xf  /mnt/efs/init/oa-init.tar
# /usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oa-init init
 

mkdir -p /openagora/oatools
/usr/bin/tar -C /openagora/oatools -xf  /mnt/efs/init/oatools.tar
#/usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oatools oatools
 
 
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



