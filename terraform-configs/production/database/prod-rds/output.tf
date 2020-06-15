output "voice-services-production-postgresql-master-endpoint" {
  description = "EndPoint "
  value       = "${aws_db_instance.voice-services-production-postgresql-master.endpoint}"
}

output "voice-services-production-postgresql-master-identifier" {
  value = "${aws_db_instance.voice-services-production-postgresql-master.id}"
}

output "rds-sg-id" {
  value = ["${aws_security_group.rds-production-sg.id}"]
}

output "rds-sub-group" {
  value = "${aws_db_subnet_group.db-rds-prd.name}"
}

output "rds-id" {
  value = "${aws_db_instance.voice-services-production-postgresql-master.id}"
}
