output "production-kubeconfig" {
  value = "${module.prod-eks.kubeconfig}"
}

output "production-config_map_aws_auth" {
  value = "${module.prod-eks.config_map_aws_auth}"
}
