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

#La llave publica de las instancias clientes en el authorized_keys del usuario al que se conecta
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD0tcFYQEiTpCfIWVPLlNHTkRL4zXeNVH3DLewSR+HvwJgl4dcTWFfsoX2KrHLv30RAqtNPZXqUwNangcBb6kX5bIw5bLy/1fHDvmnkTu51YQntWCY8uN5VdSCoxM1MMAnji2qkYvXhQYtppdA1hNUERiApNHLCg8j4kGd/uTTqqQon5xRRVomeSt43ZWcpl90MVf/7fiWl1PHWS0Fwmea3ip0HH71NHKvKhFumObdrqWjP78iUg6YMCpACCoFKCLwZ1vnYuYOOXDKOjwzBIntDu05ekUePpEQvJyeYbwQtG924U6+JRejIHxAEDF1UCp1c7aQaQPRRo/4y1fcd/snf3ZzBo7T1sS2B8oJQEW6qtl0d01jJ64SPRXiA+u4z8FXzaRJEi9j6GogowWX8hEoRVz7cBkPcdhY/1HJRrgaYfpbRmlCuxe6nCBJN3DaPgMgvAtRPeSWba6nV8XXGHVDf24bXpRN96TSIUwMCCQ5UFMtlD3PuZ9Km0rds4eUMW5lIm06b2LqH0znh+JFdLlYzSxC08jwj8QkBqaIlO3V5ZTcFM3q4g2hAYkSWM6ujTuHXqkHR1+mTDtFyRYSsGBBf8ku5iIYGEapXV2p6K6TTE+gpupXgETxq2iEaffpGkre3h1dIcQSK32gu5J6zhJ1+/NP2h9ni/LYG4iSEGwP35w== ec2-user@OAVPC" >> /home/ubuntu/.ssh/authorized_keys
