#curl -s https://raw.githubusercontent.com/openagora/ami-userdata/master/init.drp.slave1.sh | bash

#busco el bucket DRP y lo clono
/usr/bin/aws --profile oa-drp s3 sync s3://oa-drp-master s://oa-drp-slave1

#una pausa antes de terminar
sleep 300

#una vez terminado lo anterior, modifico el scalingroup del drp y lo dejo en 0
/usr/bin/aws --profile oa-drp autoscaling update-auto-scaling-group --auto-scaling-group-name oa-drp-autoscallingroup --min-size 0 --max-size 0 
