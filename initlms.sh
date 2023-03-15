#!/bin/bash -e
# este script SOLO CORRE en el primer BOOTEO de una instancia, y no en los siguientes reboot

#Ami no tiene /var/code
mkdir -p /var/code


#Creo el INIT y OATOOLS
rm -rf /openagora
mkdir -p /openagora
cd /openagora
