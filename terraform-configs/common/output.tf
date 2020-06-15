output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "internet_gateway" {
  value = "${module.vpc.internet_gateway}"
}

output "eip" {
  value = "${module.vpc.eip}"
}
