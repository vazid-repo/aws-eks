provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC - Production & Staging
module "vpc" {
  source                   = "./network"
  vpc_id                   = "${var.vpc_id}"
  internet_gateway         = "${var.internet_gateway}"
  allocation_id            = "${var.allocation_id}"
  cluster-name             = "${module.prod-eks.cluster-name}"
  prod_master_subnet_cidr  = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
  prod_worker_subnet_cidr  = ["10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
  prod_public_subnet_cidr  = ["10.0.204.0/22", "10.0.208.0/22", "10.0.212.0/22"]
  prod_private_subnet_cidr = ["10.0.228.0/22", "10.0.232.0/22", "10.0.236.0/22"]
  prod_rds_subnet_cidr     = ["10.0.246.0/23", "10.0.248.0/23", "10.0.250.0/23"]
}

module "prod-automation-server" {
  source        = "./automation-server"
  instance_type = "t3.medium"
  instance_ami  = "ami-0b99c7725b9484f9e"
  instance_key  = "${var.key}"
  vpc_id        = "${var.vpc_id}"
  k8-subnet     = "${module.vpc.prod_public_subnet[0]}"
}

module "prod-rds" {
  source             = "./database/prod-rds"
  vpc_id             = "${var.vpc_id}"
  db_size            = "92"
  db_engine          = "postgres"
  db_engine_version  = "9.6"
  db_instance_class  = "db.m5.2xlarge"
  db_name            = "postgres"
  db_username        = "postgres"
  db_password        = "2Ldppd7z4mAdk1P6"
  prod_rds_subnet    = ["${module.vpc.prod_rds_db_subnet}"]
  db_port            = "5432"
  backup_window      = "10:30-11:30"                        //Database Back window timing 
  maintenance_window = "Sun:00:00-Sun:02:00"                //Database Maintenance Windows timing
}

module "prod-replica-rds" {
  source                         = "./database/prod-rds/replica-database/"
  vpc_id                         = "${var.vpc_id}"
  db_size                        = "92"
  db_engine                      = "postgres"
  db_engine_version              = "9.6"
  db_instance_class              = "db.m5.2xlarge"
  db_name                        = "postgres"
  prod_rds_subnet                = ["${module.vpc.prod_rds_db_subnet}"]
  db_port                        = "5432"
  rds_prod_sg_id                 = ["${module.prod-rds.rds-sg-id}"]
  replicate_source_db_audiomoney = "${module.prod-rds.rds-id}"
}

module "prod-eks" {
  source                             = "./cluster"
  vpc_id                             = "${var.vpc_id}"
  prod-automation-server-instance-sg = "${module.prod-automation-server.prod-automation-server-instance-sg}"
  eks_subnets                        = ["${module.vpc.master_subnet}"]
  prod_worker_subnet                 = ["${module.vpc.prod_worker_subnet}"]
  subnet_ids                         = ["${module.vpc.master_subnet}", "${module.vpc.prod_worker_subnet}"]
}
