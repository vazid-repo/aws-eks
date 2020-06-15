#Read Replica for audiomoney slave database
resource "aws_db_instance" "voice-services-production-postgresql-slave" {
  allocated_storage = "${var.db_size}"
  storage_type      = "gp2"
  identifier        = "voice-services-production-postgresql-slave"
  engine            = "${var.db_engine}"
  engine_version    = "${var.db_engine_version}"
  instance_class    = "${var.db_instance_class}"
  name              = "${var.db_name}"

  # Username and password need not be set for replicas
  username               = ""
  password               = ""
  vpc_security_group_ids = ["${var.rds_prod_sg_id}"]
  port                   = "${var.db_port}"
  deletion_protection    = false

  # disable backups to create DB faster
  backup_retention_period = 0

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = "${var.replicate_source_db_audiomoney}"

  tags = {
    Name = "voice-services-production-postgresql-slave"
  }
}
