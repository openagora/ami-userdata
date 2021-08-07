#curl -s https://raw.githubusercontent.com/openagora/ami-userdata/master/init.drp.slave1.sh | bash

export AWS_CONFIG_FILE = "/root/.aws/config"

#busco el bucket DRP y lo clono
/usr/bin/aws s3 sync s3://oa-drp-master s3://oa-drp-slave1 --source-region us-east-1 --region us-east-1

#una pausa antes de terminar
sleep 300

#una vez terminado lo anterior, modifico el scalingroup del drp y lo dejo en 0
/usr/bin/aws autoscaling update-auto-scaling-group --auto-scaling-group-name oa-drp-autoscallingroup --min-size 0 --max-size 0 --region us-east-1
