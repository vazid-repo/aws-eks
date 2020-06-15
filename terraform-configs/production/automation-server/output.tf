output "elastic_ip" {
  value = "${aws_eip.ip.public_ip}"
}

output "prod-automation-server-instance-sg" {
  value = "${aws_security_group.prod-automation-server-instance-sg.id}"
}
