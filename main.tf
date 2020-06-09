provider "aws" {
  region = "us-east-1"
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
resource "aws_vpc" "a4_vpc_csye6225" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
      Name = "a4_vpc_csye6225"
  }
}
resource "aws_subnet" "subnet1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone1}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet1_csye6225"
  }
}
resource "aws_subnet" "subnet2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone2}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet2_csye6225"
  }
}
resource "aws_subnet" "subnet3" {
  cidr_block = "10.0.3.0/24"
  vpc_id = "${aws_vpc.a4_vpc_csye6225.id}"
  availability_zone = "${var.availablezone3}"
  map_public_ip_on_launch = true
    tags = {
      Name = "a4_subnet3_csye6225"
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
    cidr_block = "0.0.0.0/0"
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