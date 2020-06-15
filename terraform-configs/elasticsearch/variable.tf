variable "region" {
  description = "AWS Region"
  default = "ap-south-1"
}

variable "profile" {
  description = "AWS Profile "
  default = "default"
}

variable "domain_name" {
  description = "Elastic Search Domain Name"
}

variable "elasticsearch_version" {
  description = "Elastic Search version"
  default = 6.7
}