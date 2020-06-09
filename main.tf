provider "aws" {
  region = "us-east-1"
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
resource "aws_vpc" "a4_vpc_csye6225" {
  cidr_block = "${var.vpccider}"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
      Name = "${var.vpctag}"
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