variable "staging_public_subnet_cidr" {
  description = "Kubernetes Public CIDR"
  type        = "list"
}

variable "staging_private_subnet_cidr" {
  type        = "list"
  description = "Kubernetes Private CIDR"
}

variable "vpc_id" {
  description = "Vpc id of vernacular vpc"
}

variable "staging_master_subnet_cidr" {
  type        = "list"
  description = "CIDR for master subnet"
  default     = []
}

variable "staging_worker_subnet_cidr" {
  type        = "list"
  description = "CIDR for worker subnet"
  default     = []
}

variable "staging_rds_subnet_cidr" {
  type        = "list"
  description = "CIDR for rds subnet"
  default     = []
}

variable "cluster-name" {}

variable "internet_gateway" {}
