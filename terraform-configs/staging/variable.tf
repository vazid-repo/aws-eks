variable "profile" {
  description = "AWS user account"
}

variable "internet_gateway" {}

variable "vpc_id" {}

variable "key" {
  default = "tesult-vernacular"
}

variable "region" {
  default = "ap-south-1"
}

#EKS Cluster Variable

variable "instance_type" {
  description = "Spot instance type "
}

variable "instance_type1" {
  description = "Spot instance type "
}

variable "min_size" {
  description = "Minimum worker capacity in the autoscaling group"
}

variable "max_size" {
  description = "Maximum worker capacity in the autoscaling group"
}

variable "desired_capacity" {
  description = "Desired worker capacity in the autoscaling group"
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances"
}

variable "on_demand_percentage" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity."
}

variable "spot_max_price" {
  description = "Maximum price per unit hour for the Spot instances.In Dollor eg - 2"
}
