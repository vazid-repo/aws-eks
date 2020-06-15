#RDS Variable
variable "prod_rds_subnet" {
  description = "Production RDS Subnet ids"
  type        = "list"
}

variable "db_size" {
  description = "Database size"
}

variable "db_engine" {
  description = "Type of database used in RDS"
}

variable "db_engine_version" {
  description = "Database Version"
}

variable "db_instance_class" {
  description = "Database Instace type"
}

variable "db_name" {
  description = "Database name"
}

variable "multi_az" {
  default = true
}

variable "db_port" {
  description = "Database port number"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "replicate_source_db_audiomoney" {
  description = "Endpoint for voice-services-production-postgresql-master"
}

variable "rds_prod_sg_id" {
  description = "Production rds security group ids"
  type        = "list"
}
