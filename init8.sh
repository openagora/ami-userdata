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
#yum -y install nvme-cli
#yum -y install sshpass --enablerepo epel
#yum -y install ImageMagick
#yum -y install php-xmlrpc.x86_64
#yum -y install php-sodium.x86_64
#yum -y install oathtool --enablerepo=epel 

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

#actualizo la instancia (solo parches de seguridad)
yum -y update --security --exclude=python*

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
 
 
# INICIO PHP8
# INICIO PHP8
# INICIO PHP8

# Elimino php actual
#yum remove -y php-* 

# actualizo lo que queda
#yum -y update
#yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
#yum clean metadata

# preparo los repositorios desde donde obtengo los paquetes
#yum-config-manager --disable 'remi-php*'
#amazon-linux-extras disable php7.3 
#yum-config-manager --enable remi-php81
#yum-config-manager --enable epel

# Cambio prioridades de  remi-php81 , priority=1
#con esto, podré hacer un DROP-IN REPLACEMENT de los binarios y archivos de configuracion
#sed -i '/^enabled=1/a priority=1' /etc/yum.repos.d/remi-php81.repo  
#cat /etc/yum.repos.d/remi-php81.repo 

#yum -y  install php-{cli,common,fpm,gd,gmp,intl,json,mbstring,mysqlnd,opcache,pdo,pecl-apcu,pecl-igbinary,pecl-memcached,pecl-msgpack,pecl-redis,pgsql,soap,sodium,xml,xmlrpc}

# chao epel
#yum-config-manager --disable epel

# TUNNING
#opcache.memory_consumption=160
#sed -i 's/^;opcache.memory_consumption=.*/opcache.memory_consumption=160/g' /etc/php.d/10-opcache.ini 

#opcache.interned_strings_buffer=16
#sed -i 's/^;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/g' /etc/php.d/10-opcache.ini 

#opcache.max_accelerated_files=5000
#sed -i 's/^;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=5000/g' /etc/php.d/10-opcache.ini 

#opcache.huge_code_pages=1
#sed -i 's/^opcache.huge_code_pages=0/opcache.huge_code_pages=1/g' /etc/php.d/10-opcache.ini 

# Actualizacion de ioncube con Respaldo Manager
rm /etc/php.d/10-ioncube.ini
rm /openagora/conf/lib64/ioncube_loader_lin_7.3.so
rm -rf /home/ec2-user/ioncube 


# FIN PHP8
# FIN PHP8
# FIN PHP8

#limpieza a los LOGS
for logfile in $(find /var/log/ -type f )
do 
  truncate -s 0 $logfile
done
truncate -s 0 /home/ec2-user/.bash_history 
 
 
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
