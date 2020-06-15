#
# Variables Configuration
#
variable "cluster-name" {
  default = "voice-services-staging-cluster"
  type    = "string"
}

variable "vpc_id" {
  description = "VPC ID "
}

variable "eks_subnets" {
  description = "Master subnet ids"
  type        = "list"
}

variable "staging_worker_subnet" {
  type = "list"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of all subnet in cluster"
}

variable "staging-automation-server-instance-sg" {
  description = "Kubenetes control server security group"
}

variable "instance_type" {
  description = "Spot instance type "
}

variable "instance_type1" {
  description = "Spot instance type "
}

variable "min_size" {}

variable "max_size" {}

variable "desired_capacity" {}

variable "on_demand_base_capacity" {}

variable "on_demand_percentage" {}

variable "spot_instance_pools" {}

variable "spot_max_price" {}
