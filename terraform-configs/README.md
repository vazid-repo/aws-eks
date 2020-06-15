# terraform-configs

## Pre-Requisite

### Setup Terraform version 11.14

1. Download [Terraform 11.14](https://releases.hashicorp.com/terraform/)
2. Unzip and move `terraform` executable to `/usr/local/bin/`

```sh
 terraform -v
```

### Configure AWS credentials

```sh
aws configure
```

## Getting Started

### Create common VPC, NAT Gateway & Subnets

Note:  If you have already setup VPC, don't apply these terraform changes.

```sh
cd common
terraform init
terraform plan
terraform apply
```

It will create EIP, Internet Gateway, VPC CIDR store it somewhere for future reference.

### Setup ElasticSearch

```sh
cd elasticsearch
terraform init
terraform plan
terraform apply
```

### Setup Automation Server, EKS and RDS

```sh
cd production
terraform init
terraform plan -var-file=production.tfvars
terraform apply -var-file=production.tfvars
```

### Setup Spot Instance

```sh
cd spot-instance
terraform init
terraform plan
terraform apply
```

To backup AMI,

```sh
cd backup_ami
terraform init
terraform plan
terraform apply
```