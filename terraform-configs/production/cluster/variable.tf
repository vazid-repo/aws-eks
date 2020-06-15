#
# Variables Configuration
#

variable "cluster-name" {
  default = "voice-services-production-cluster"
  type    = "string"
}

variable "vpc_id" {
  description = "VPC ID "
}

variable "eks_subnets" {
  description = "Master subnet ids"
  type        = "list"
}

variable "prod_worker_subnet" {
  type = "list"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of all subnet in cluster"
}

variable "prod-automation-server-instance-sg" {
  description = "Kubenetes control server security group"
}
