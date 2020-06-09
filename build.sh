#!/bin/bash

terraform init
terraform plan -var="availablezone1=us-east-1a" \
               -var="availablezone2=us-east-1b" \
               -var="availablezone3=us-east-1c" 
terraform apply -auto-approve -var="availablezone1=us-east-1a" \
                              -var="availablezone2=us-east-1b" \
                              -var="availablezone3=us-east-1c"