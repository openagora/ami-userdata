#!/bin/bash
set -e

# Update sistema
apt update && apt upgrade -y

# Instalar dependencias básicas
apt install -y software-properties-common dirmngr gnupg apt-transport-https ca-certificates curl build-essential

# ----------------------
# Instalar R desde CRAN
# ----------------------

# Agregar llave y repositorio de CRAN para Ubuntu 22.04
curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/cran.gpg
echo "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" > /etc/apt/sources.list.d/cran.list

# Actualizar e instalar R base
apt update
apt install -y r-base

# ----------------------
# Instalar Python y pip
# ----------------------

apt install -y python3 python3-pip python3-venv

# Instalar algunos paquetes comunes
pip3 install numpy pandas 

