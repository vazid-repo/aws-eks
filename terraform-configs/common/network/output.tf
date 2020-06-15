output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${aws_vpc.this.cidr_block}"
}

output "internet_gateway" {
  value = "${aws_internet_gateway.igw.id}"
}

output "eip" {
  value = "${aws_eip.eip.id}"
}
