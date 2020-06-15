#Security Group
resource "aws_security_group" "rds-staging-sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "staging RDS Security Group"
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
    Name        = "staging-rds-sg"
    Enviornment = "staging"
  }
}

#Subnet Group
resource "aws_db_subnet_group" "db-rds-stag" {
  subnet_ids  = ["${var.staging_rds_subnet}"]
  name        = "staging-rds-subnet-group"
  description = "Subnet group for staging RDS "

  tags = {
    Name = "staging-rds-subnet-group"
  }
}

# RDS
# voice service staging postgresql 96 replica 
resource "aws_db_instance" "voice-services-staging-postgresql-master" {
  allocated_storage      = "${var.db_size}"
  storage_type           = "gp2"
  identifier             = "voice-services-staging-postgresql-master"
  engine                 = "${var.db_engine}"
  engine_version         = "${var.db_engine_version}"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  publicly_accessible    = false
  multi_az               = true
  vpc_security_group_ids = ["${aws_security_group.rds-staging-sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db-rds-stag.name}"
  port                   = "${var.db_port}"
  deletion_protection    = false
  backup_window          = "${var.backup_window}"
  maintenance_window     = "${var.maintenance_window}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "voice-services-staging-postgresql-master-snapshots"

  # Backups are required in order to create a replica
  backup_retention_period = 1

  tags = {
    Name        = "voice-services-staging-postgresql-master"
    Enviornment = "staging"
  }
}
