#!/bin/bash

# Variables
ENI_ID="eni-0a85634f86e7cc2a3"  # ENI
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION="us-east-1" 

# Log para debugging
exec > >(tee /var/log/eni-attach.log)
exec 2>&1

echo "Iniciando proceso de ENI attach para instancia: $INSTANCE_ID"

# 1. Detach forzoso del ENI (sin importar dónde esté)
echo "Haciendo detach forzoso del ENI..."
aws ec2 detach-network-interface \
    --network-interface-id $ENI_ID \
    --region $REGION \
    --force || echo "ENI ya estaba detached o error en detach"

# 2. Esperar un poco para que el detach se complete
echo "Esperando 10 segundos..."
sleep 10

# 3. Attach a esta instancia
echo "Attachando ENI a esta instancia..."
aws ec2 attach-network-interface \
    --network-interface-id $ENI_ID \
    --instance-id $INSTANCE_ID \
    --device-index 1 \
    --region $REGION

# 4. Verificar que se attachó correctamente
if [ $? -eq 0 ]; then
    echo "ENI attachado exitosamente"
    # Configurar la interfaz de red en el OS
    sudo dhclient eth1
else
    echo "Error al attachar ENI"
    exit 1
fi

