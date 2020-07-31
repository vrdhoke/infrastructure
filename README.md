# infrastructure

Infrastructure as Code with Terraform

main.tf file will create the resources such as VPCs ,Subnet, Route Table,Internet Gateways

Variables will be passed from command line while executing the main.tf file

Commands for terraform to create the resources are

terraform init

terraform plan

terraform apply


# Command to import the SSL certificate to AWS for LoadBalancers 
aws acm import-certificate --certificate fileb://prod_vaibhavdhoke_me.crt --private-key fileb://vaibhavdhoke.key \ --certificate-chain fileb://prod_vaibhavdhoke_me.ca-bundle
