variable "vpc_id" {
  description = "VPC ID"  
}

variable "key" {
  default = "tesult-vernacular"
}

variable "internet_gateway" {
  description = "VPCs Internet gateway ID"
}

variable "allocation_id" {
  description = "Elastic IPs Allocation ID"
}

variable "region" {
  default = "ap-south-1"
}

variable "profile" {
  description = "AWS user account profile"
}
