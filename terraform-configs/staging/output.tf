output "staging-kubeconfig" {
  value = "${module.eks.kubeconfig}"
}
output "staging-config_map_aws_auth" {
  value = "${module.eks.config_map_aws_auth}"
}

