#!/bin/bash

terraform init
terraform plan -var="vpccider=10.0.0.0/24" \
               -var="subnet1cider=10.0.0.0/26" \
               -var="subnet2cider=10.0.0.64/26" \
               -var="subnet3cider=10.0.0.128/25" \
               -var="routedestcidr=0.0.0.0/0" \
               -var="region=us-east-1" \
               -var="availablezone1=us-east-1a" \
               -var="availablezone2=us-east-1b" \
               -var="availablezone3=us-east-1c" \
               -var="vpctag=a4_vpc_csye6225" \
               -var="ami_id=ami-05e623ee887a22b09" \
               -var="rds_username=csye6225_su2020" \
               -var="rds_password=vrd141293" \
               -var="db_name=csye6225" 
terraform apply -auto-approve -var="vpccider=10.0.0.0/24" \
                              -var="subnet1cider=10.0.0.0/26" \
                              -var="subnet2cider=10.0.0.64/26" \
                              -var="subnet3cider=10.0.0.128/25" \
                              -var="routedestcidr=0.0.0.0/0" \
                              -var="region=us-east-1" \
                              -var="availablezone1=us-east-1a" \
                              -var="availablezone2=us-east-1b" \
                              -var="availablezone3=us-east-1c" \
                              -var="vpctag=a4_vpc_csye6225" \
                              -var="ami_id=ami-05e623ee887a22b09" \
                              -var="rds_username=csye6225_su2020" \
                              -var="rds_password=vrd141293" \
                              -var="db_name=csye6225" 