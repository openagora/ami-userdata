#!/bin/bash

# Variables
ENI_ID="eni-0a85634f86e7cc2a3"  # ENI
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION="us-east-1" 

# Log para debugging
exec > >(tee /var/log/eni-attach.log)
exec 2>&1

echo "Iniciando proceso de ENI attach para instancia: $INSTANCE_ID"

# 1. Obtener attachment-id del ENI (si está attached)
echo "Verificando estado del ENI..."
ATTACHMENT_ID=$(aws ec2 describe-network-interfaces \
    --network-interface-ids $ENI_ID \
    --region $REGION \
    --query 'NetworkInterfaces[0].Attachment.AttachmentId' \
    --output text)

# 2. Detach solo si está attached
if [ "$ATTACHMENT_ID" != "None" ] && [ "$ATTACHMENT_ID" != "" ]; then
    echo "ENI está attached con ID: $ATTACHMENT_ID"
    echo "Haciendo detach forzoso..."
    aws ec2 detach-network-interface \
        --attachment-id $ATTACHMENT_ID \
        --region $REGION \
        --force
    echo "Esperando que el detach se complete..."
    sleep 15
else
    echo "ENI ya estaba detached"
fi

# 3. Attach a esta instancia
echo "Attachando ENI a esta instancia..."
aws ec2 attach-network-interface \
    --network-interface-id $ENI_ID \
    --instance-id $INSTANCE_ID \
    --device-index 1 \
    --region $REGION

# 4. Verificar y configurar la interfaz
if [ $? -eq 0 ]; then
    echo "ENI attachado exitosamente"
    # Esperar un poco y configurar la interfaz
    sleep 5
    sudo dhclient eth1 2>/dev/null || sudo dhclient ens6 2>/dev/null
    echo "Interfaz de red configurada"
else
    echo "Error al attachar ENI"
    exit 1
fi
