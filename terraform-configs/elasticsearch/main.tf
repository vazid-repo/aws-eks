data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_elasticsearch_domain" "voice-services-es" {
  domain_name           = "${var.domain_name}"
  elasticsearch_version = "${var.elasticsearch_version}"

  ebs_options {
    ebs_enabled = true
    volume_size = "50"
    volume_type = "gp2"
  }

  cluster_config {
    instance_type = "m5.large.elasticsearch"
  }

  tags = {
    Domain = "voice-services-es"
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*",
      "Condition": {
        "IpAddress": {"aws:SourceIp": ["122.166.167.233","13.234.157.127","49.204.64.11","49.204.64.12", "106.51.24.212","106.51.22.184","35.200.169.172","13.127.6.174"]}
      }
    }
  ]
}
POLICY
}
