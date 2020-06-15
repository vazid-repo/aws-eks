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
  description = "Database version Eg-9.6"
}

variable "db_instance_class" {
  description = "Database Instace type"
}

variable "db_name" {
  description = "Database name"
}

variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
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

variable "backup_window" {
  description = "Define Backup window time range (in UTC)"
}

variable "maintenance_window" {
  description = "To perform maintenance Windows"
}
