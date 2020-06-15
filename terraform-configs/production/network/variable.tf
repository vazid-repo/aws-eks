variable "prod_public_subnet_cidr" {
  description = "Kubernetes Public CIDR"
  type        = "list"
}

variable "prod_private_subnet_cidr" {
  type        = "list"
  description = "Kubernetes Private CIDR"
}

variable "vpc_id" {
  description = "Vpc id of vernacular vpc"
}

variable "prod_master_subnet_cidr" {
  type        = "list"
  description = "CIDR for master subnet"
  default     = []
}

variable "prod_worker_subnet_cidr" {
  type        = "list"
  description = "CIDR for worker subnet"
  default     = []
}

variable "prod_rds_subnet_cidr" {
  type        = "list"
  description = "CIDR for rds subnet"
  default     = []
}

variable "internet_gateway" {}

variable "allocation_id" {}

variable "cluster-name" {}
