output "staging_public_subnet" {
  value = "${aws_subnet.staging_public_subnet.*.id}"
}

output "staging_master_subnet" {
  value = "${aws_subnet.staging_master_subnet.*.id}"
}

output "staging_worker_subnet" {
  value = "${aws_subnet.staging_worker_subnet.*.id}"
}

output "staging_rds_db_subnet" {
  value = "${aws_subnet.staging_rds_subnet.*.id}"
}
