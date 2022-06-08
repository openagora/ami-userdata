#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

#Ami no tiene /var/code
mkdir -p /var/code


#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora


echo "SMALL" > /var/code/WORKER.SIZE

#YUM INSTALL
yum -y install nvme-cli
yum -y install sshpass --enablerepo epel
yum -y install ImageMagick



if /sbin/nvme -list | /bin/grep -q "Instance Storage" ; then

  #el working dir DEBE SER el ephemeral
  echo "LARGE" > /var/code/WORKER.SIZE

  EPHEMERAL_DISK=$(/sbin/nvme list | grep 'Instance Storage' | awk '{ print $1 }')
  /usr/sbin/mkfs.xfs $EPHEMERAL_DISK
  /usr/bin/mount -t xfs $EPHEMERAL_DISK /mnt/ephemeral0

  EPHEMERAL_UUID=$(sudo blkid -s UUID -o value $EPHEMERAL_DISK)

  mkdir -p -m 1777 /mnt/ephemeral0/tmp

  echo "UUID=$EPHEMERAL_UUID /mnt/ephemeral0 xfs defaults,nofail 0 2" |  tee -a /etc/fstab
  echo "/mnt/ephemeral0/tmp /tmp  none rw,noexec,nofail,bind 0 0" |  tee -a /etc/fstab

  mkdir -p /mnt/ephemeral0/codetmp
  /usr/bin/chown ec2-user:ec2-user /mnt/ephemeral0/codetmp

  /bin/ln -s  /mnt/ephemeral0/codetmp /var/code/tmp
  /usr/bin/chown -h ec2-user:ec2-user /var/code/tmp
else
   rm -rf /mnt/ephemeral0
fi

#actualizo la instancia
yum -y update --exclude=python*

#Julio2021
# awscli fue instalado usando pip de python3 para poder tener awscli 2.x

/usr/bin/aws configure set region us-east-1
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
/usr/bin/git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.UseHttpPath true


#################
###### S3FS #####

# basado en:   --- > https://github.com/s3fs-fuse/s3fs-fuse/wiki/Fuse-Over-Amazon

#calculo el ROL de la INSTANCIA
IAMROLE=$(curl http://169.254.169.254/latest/meta-data/iam/info -s | jq .InstanceProfileArn | xargs basename)

#montaje manual:
#s3fs oadeploy -o iam_role=${IAMROLE} -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp /mnt/s3fs

#montaje por FSTAB:
echo "s3fs#oadeploy /mnt/s3fs fuse _netdev,allow_other,iam_role=${IAMROLE},use_cache=/tmp,url=https://s3.us-east-1.amazonaws.com 0 0" |  tee -a /etc/fstab
mount /mnt/s3fs


#################

mkdir -p /openagora/init
/usr/bin/tar -C /openagora/init -xf  /mnt/s3fs/init/oa-init.tar
# /usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oa-init init
 

mkdir -p /openagora/oatools
/usr/bin/tar -C /openagora/oatools -xf  /mnt/s3fs/init/oatools.tar
#/usr/bin/git clone --depth 1 https://git-codecommit.us-east-1.amazonaws.com/v1/repos/oatools oatools
 
 
#lanzo la configuracion INICIAL
/openagora/init/initAPP.sh initconf
 
#correccion de propietarios
chown ec2-user:ec2-user -R /var/code
chown ec2-user:ec2-user -R /openagora

#suponiendo que existe
chown ec2-user:ec2-user -R /mnt/ephemeral0/codetmp
 
#Borro el bash_history
cat /dev/null > ~/.bash_history && history -c
rm -rf /home/ec2-user/.bash_history
  
 
#EOF
shutdown now -r



