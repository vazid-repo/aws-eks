output "voice-services-staging-postgresql-master-endpoint" {
  description = "EndPoint "
  value       = "${aws_db_instance.voice-services-staging-postgresql-master.endpoint}"
}

output "voice-services-staging-postgresql-master-identifier" {
  value = "${aws_db_instance.voice-services-staging-postgresql-master.id}"
}

output "rds-sg-id" {
  value = ["${aws_security_group.rds-staging-sg.id}"]
}

output "rds-sub-group" {
  value = "${aws_db_subnet_group.db-rds-stag.name}"
}

output "rds-id" {
  value = "${aws_db_instance.voice-services-staging-postgresql-master.id}"
}
