#Security Group
resource "aws_security_group" "rds-production-sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "Production RDS Security Group"
  description = "Security group for RDS Instance"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["122.166.167.233/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "Production-rds-sg"
    Enviornment = "Production"
  }
}

#Subnet Group
resource "aws_db_subnet_group" "db-rds-prd" {
  subnet_ids  = ["${var.prod_rds_subnet}"]
  name        = "prod-rds-subnet-group"
  description = "Subnet group for Production RDS "

  tags = {
    Name = "Production-rds-subnet-group"
  }
}

# RDS
# voice service production postgresql 96 replica 
resource "aws_db_instance" "voice-services-production-postgresql-master" {
  allocated_storage      = "${var.db_size}"
  storage_type           = "gp2"
  identifier             = "voice-services-production-postgresql-master"
  engine                 = "${var.db_engine}"
  engine_version         = "${var.db_engine_version}"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  publicly_accessible    = false
  multi_az               = true
  vpc_security_group_ids = ["${aws_security_group.rds-production-sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db-rds-prd.name}"
  port                   = "${var.db_port}"
  deletion_protection    = false
  backup_window          = "${var.backup_window}"
  maintenance_window     = "${var.maintenance_window}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "voice-services-production-postgresql-master-snapshots"

  # Backups are required in order to create a replica
  backup_retention_period = 1

  tags = {
    Name        = "voice-services-production-postgresql-master"
    Enviornment = "Production"
  }
}
