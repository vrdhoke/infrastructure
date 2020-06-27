variable "region" {
  type = "string"
}

variable "vpccider" {
  type = "string"
}
variable "subnet1cider" {
  type = "string"
}
variable "subnet2cider" {
  type = "string"
}
variable "subnet3cider" {
  type = "string"
}
variable "routedestcidr" {
  type = "string"
}
variable "availablezone1" {
  type = "string"
}
variable "availablezone2" {
  type = "string"
}
variable "availablezone3" {
  type = "string"
}
variable "vpctag" {
  type = "string"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "a4_vpc_csye6225" {
  cidr_block = "${var.vpccider}"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
      Name = "${var.vpctag}"
      Environment = "${terraform.workspace}"
  }
}
resource "aws_subnet" "subnet1" {
  cidr_block = "${var.subnet1cider}"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone1}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  cidr_block = "${var.subnet2cider}"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone2}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet2"
  }
}
resource "aws_subnet" "subnet3" {
  cidr_block = "${var.subnet3cider}"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone3}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet3"
  }
}
resource "aws_internet_gateway" "internet_gateway_csye6225" {
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  tags = {
    Name = "internet_gateway_csye6225"
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  route {
    cidr_block = "${var.routedestcidr}"
    gateway_id = "${aws_internet_gateway.internet_gateway_csye6225.id}"
  }

  tags = {
    Name = "route_table"
  }
}
resource "aws_route_table_association" "association1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
resource "aws_route_table_association" "association2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
resource "aws_route_table_association" "association3" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}


resource "aws_security_group" "application" {
  name        = "application"
  description = "Security group for Book Web Application"
  vpc_id      = "${aws_vpc.a4_vpc_csye6225.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "database" {
  name        = "database"
  description = "Security group for RDS instance in AWS"
  vpc_id      = "${aws_vpc.a4_vpc_csye6225.id}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.a4_vpc_csye6225.cidr_block]
    security_groups = ["${aws_security_group.application.id}"]
  }
}
resource "aws_s3_bucket" "bucket" {
  bucket = "webapp.vaibhav.dhoke"
  acl    = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  lifecycle_rule {
    id      = "move"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
resource "aws_db_subnet_group" "databasesubnet" {
  name       = "databasesubnetgroup"
  subnet_ids = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}", "${aws_subnet.subnet3.id}"]
}

variable "rds_username" {
  type = "string"
}
variable "rds_password" {
  type = "string"
}
variable "db_name" {
  type = "string"
}


resource "aws_db_instance" "csye6225-su2020" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  identifier             = "csye6225-su2020"
  username               = "${var.rds_username}"
  password               = "${var.rds_password}"
  publicly_accessible    = "false"
  skip_final_snapshot = true
  name                   = "${var.db_name}"
  multi_az               = "false"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.databasesubnet.name}"
}

variable "ami_id" {
  type = "string"
}
variable "ec2_s3iamprofile" {
  type = "string"
}

resource "aws_iam_instance_profile" "ec2_s3iamprofile" {
  name = "${var.ec2_s3iamprofile}"
  role = "${aws_iam_role.role.name}"
}

resource "aws_instance" "web" {
  ami                     = "${var.ami_id}"
  instance_type           = "t2.micro"
  disable_api_termination = "false"
  subnet_id               = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids  = ["${aws_security_group.application.id}"]
  depends_on              = [aws_db_instance.csye6225-su2020]
  key_name                = "csye6225_su20_aws"
  iam_instance_profile    = "${aws_iam_instance_profile.ec2_s3iamprofile.name}"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = "true"
  }
  tags = {
    Name = "EC2 Instance from Terraform",
    cicd = "codedeploy"
  }
  user_data = <<-EOFS
#!/bin/bash
sudo mkdir /home/ubuntu/webapp
sudo chmod 755 /home/ubuntu/webapp
sudo mkdir /home/ubuntu/webapp/config
cat > /home/ubuntu/webapp/config/config.json << EOF
{
"development": {
    "username": "${aws_db_instance.csye6225-su2020.username}",
    "password": "${aws_db_instance.csye6225-su2020.password}",
    "database": "${aws_db_instance.csye6225-su2020.name}",
    "host": "${aws_db_instance.csye6225-su2020.address}",
    "dialect": "mysql",
    "operatorsAliases": false,
    "s3bucket": "${aws_s3_bucket.bucket.bucket}",
    "region": "${var.region}"
  }
}
EOF
EOFS
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = "csye6225"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
  read_capacity  = 20
  write_capacity = 20
}

variable "images3bucket" {
  type = "string"
}

resource "aws_iam_policy" "policy" {
  name        = "WebAppS3"
  description = "EC2 S3 policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.images3bucket}",
                "arn:aws:s3:::${var.images3bucket}/*"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_role" "role" {
  name = "EC2-CSYE6225"
  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "rolepolicyattachment" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_role_policy_attachment" "rolepolicyattachment1" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy1.arn}"
}

variable "codedeploy_bktname" {
  type = "string"
}

resource "aws_iam_policy" "policy1" {
  name        = "CodeDeploy-EC2-S3"
  description = "This policy allows EC2 instances to read data from S3 buckets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
              "s3:GetObject",
              "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.codedeploy_bktname}",
                "arn:aws:s3:::${var.codedeploy_bktname}/*"
            ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy2" {
  name        = "CircleCI-Upload-To-S3"
  description = "This policy allows CircleCI to upload artifacts from latest successful build to dedicated S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.codedeploy_bktname}",
                "arn:aws:s3:::${var.codedeploy_bktname}/*"
            ]
    }
  ]
}
EOF
}

variable "aws_account_id" {
  type = "string"
}


resource "aws_iam_policy" "policy3" {
  name        = "CircleCI-Code-Deploy"
  description = "This policy allows allows CircleCI to call CodeDeploy APIs to initiate application deployment on EC2 instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${var.aws_account_id}:application:csye6225-webapp"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${var.aws_account_id}:deploymentgroup:csye6225-webapp/csye6225-webapp-deployment"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}

variable "circleciuser" {
  type = "string"
}

variable "packerpolicy" {
  type = "string"
}

resource "aws_iam_user_policy_attachment" "cicd-attach" {
  user       = "${var.circleciuser}"
  policy_arn = "${aws_iam_policy.policy2.arn}"
}

resource "aws_iam_user_policy_attachment" "cicd-attach1" {
  user       = "${var.circleciuser}"
  policy_arn = "${aws_iam_policy.policy3.arn}"
}

resource "aws_iam_user_policy_attachment" "cicd-attach2" {
  user       = "${var.circleciuser}"
  policy_arn = "${var.packerpolicy}"
}

resource "aws_iam_role" "role1" {
  name = "CodeDeployEC2ServiceRole"
  description = "Allows EC2 instances to call AWS services on your behalf"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.role1.name}"
  policy_arn = "${aws_iam_policy.policy1.arn}"
}

resource "aws_iam_role" "role2" {
  name = "CodeDeployServiceRole"
  description = "Allows EC2 instances to call AWS services on your behalf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "test-attach1" {
  role       = "${aws_iam_role.role2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "csye6225-webapp" {
  compute_platform = "Server"
  name             = "csye6225-webapp"
}

resource "aws_codedeploy_deployment_group" "csye6225-webapp-deployment" {
  app_name              = "${aws_codedeploy_app.csye6225-webapp.name}"
  deployment_group_name = "csye6225-webapp-deployment"
  service_role_arn      = "${aws_iam_role.role2.arn}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "cicd"
      type  = "KEY_AND_VALUE"
      value = "codedeploy"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

