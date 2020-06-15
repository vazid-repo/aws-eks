output "elastic_ip" {
  value = "${aws_eip.ip.public_ip}"
}

output "staging-automation-server-instance-sg" {
  value = "${aws_security_group.staging-automation-server-instance-sg.id}"
}
