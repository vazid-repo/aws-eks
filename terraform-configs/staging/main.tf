provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

#Staging Network 
module "vpc" {
  source                      = "./network"
  internet_gateway            = "${var.internet_gateway}"
  vpc_id                      = "${var.vpc_id}"
  cluster-name                = "${module.eks.cluster-name}"
  staging_master_subnet_cidr  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  staging_worker_subnet_cidr  = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
  staging_public_subnet_cidr  = ["10.0.192.0/22", "10.0.196.0/22", "10.0.200.0/22"]
  staging_private_subnet_cidr = ["10.0.216.0/22", "10.0.220.0/22", "10.0.224.0/22"]
  staging_rds_subnet_cidr     = ["10.0.240.0/23", "10.0.242.0/23", "10.0.244.0/23"]
}

#Staging - Automation Server
module "k8" {
  source        = "./automation-server"
  region        = "${var.region}"
  profile       = "${var.profile}"
  cluster-name  = "${module.eks.cluster-name}"
  instance_type = "t3.medium"
  instance_ami  = "ami-0b99c7725b9484f9e"
  instance_key  = "${var.key}"
  vpc_id        = "${var.vpc_id}"
  k8-subnet     = "${module.vpc.staging_public_subnet[0]}"
}

# Staging - EKS Cluster
module "eks" {
  source                                = "./cluster"
  vpc_id                                = "${var.vpc_id}"
  staging-automation-server-instance-sg = "${module.k8.staging-automation-server-instance-sg}"
  eks_subnets                           = ["${module.vpc.staging_master_subnet}"]
  staging_worker_subnet                 = ["${module.vpc.staging_worker_subnet}"]
  subnet_ids                            = ["${module.vpc.staging_master_subnet}", "${module.vpc.staging_worker_subnet}"]
  instance_type                         = "${var.instance_type}"
  instance_type1                        = "${var.instance_type1}"
  min_size                              = "${var.min_size}"
  max_size                              = "${var.max_size}"
  desired_capacity                      = "${var.desired_capacity}"
  on_demand_base_capacity               = "${var.on_demand_base_capacity}"
  on_demand_percentage                  = "${var.on_demand_percentage}"
  spot_instance_pools                   = "${var.spot_instance_pools}"
  spot_max_price                        = "${var.spot_max_price}"
}

module "stag-rds" {
  source             = "./database"
  vpc_id             = "${var.vpc_id}"
  db_size            = "40"
  db_engine          = "postgres"
  db_engine_version  = "9.6"
  db_instance_class  = "db.t2.micro"
  db_name            = "postgres"
  db_username        = "postgres"
  db_password        = "2Ldppd7z4mAdk1P6"
  staging_rds_subnet = ["${module.vpc.staging_rds_db_subnet}"]
  db_port            = "5432"
  backup_window      = "10:30-11:30"                           //Database Back window timing 
  maintenance_window = "Sun:00:00-Sun:02:00"                   //Database Maintenance Windows timing
}
