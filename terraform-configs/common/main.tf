provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC - Production & Staging
module "vpc" {
  source = "./network"
  cidr   = "10.0.0.0/16"
}
