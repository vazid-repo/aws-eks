output "prod_public_subnet" {
  value = "${aws_subnet.prod_public_subnet.*.id}"
}

output "master_subnet" {
  value = "${aws_subnet.prod_master_subnet.*.id}"
}

output "prod_worker_subnet" {
  value = "${aws_subnet.prod_worker_subnet.*.id}"
}

output "prod_rds_db_subnet" {
  value = "${aws_subnet.prod_rds_subnet.*.id}"
}
