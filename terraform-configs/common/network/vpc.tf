data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"

  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "vernacular-vpc"
  }
}

#VPC Elastic IP
resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "vernacular_eip"
  }
}

#Internet Gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "Internet-Gateway"
  }
}
