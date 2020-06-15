#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

#IAM Role
resource "aws_iam_role" "prod-worker-node-role" {
  name = "voice-services-production-worker-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "production-eks-tagging" {
  name        = "production_resource_tagging_for_eks"
  path        = "/"
  description = "resource_tagging_for_eks"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:UntagResources",
                "tag:GetTagValues",
                "tag:GetTagKeys",
                "tag:TagResources"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ClusterAutoScaler" {
  name = "ClusterAutoScaler-Prod"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "production-worker-node-clusterautoscaler" {
  policy_arn = "${aws_iam_policy.ClusterAutoScaler.arn}"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-worker-node-resource_tagging_for_eks" {
  policy_arn = "${aws_iam_policy.production-eks-tagging.arn}"
  role       = "${aws_iam_role.prod-worker-node-role.name}"
}

resource "aws_iam_instance_profile" "prod-worker-node" {
  name = "prod-eks-worker"
  role = "${aws_iam_role.prod-worker-node-role.name}"
}

#Security Group
resource "aws_security_group" "prod-worker-node-sg" {
  name        = "prod-worker-nodeSG"
  description = "Security group for all nodes in the production cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                   = "prod-worker-node-sg"
    "kubernetes.io/cluster/" = "${var.cluster-name}"
  }
}

resource "aws_security_group_rule" "prod-worker-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.prod-worker-node-sg.id}"
  source_security_group_id = "${aws_security_group.prod-worker-node-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "prod-worker-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.prod-worker-node-sg.id}"
  source_security_group_id = "${aws_security_group.prod-cluster-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "prod-worker-node-for-control-server" {
  description              = "Allow worker Kubelets and pods to receive communication from the control server"
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.prod-worker-node-sg.id}"
  source_security_group_id = "${var.prod-automation-server-instance-sg}"
  to_port                  = 65535
  type                     = "ingress"
}

# resource "aws_security_group_rule" "prod-worker-node-for-alb" {
#   description              = "Allow worker Kubelets and pods to receive communication from alb"
#   from_port                = 0
#   protocol                 = "tcp"
#   security_group_id        = "${aws_security_group.prod-worker-node-sg.id}"
#   source_security_group_id = "${aws_security_group.prod_eks_alb_sg.id}"
#   to_port                  = 65535
#   type                     = "ingress"
# }

data "aws_ami" "prod-eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks-prod-cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

locals {
  worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-prod-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-prod-cluster.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

#Launch Configuration
resource "aws_launch_configuration" "worker" {
  iam_instance_profile = "${aws_iam_instance_profile.prod-worker-node.name}"
  image_id             = "${data.aws_ami.prod-eks-worker.id}"
  instance_type        = "m5.2xlarge"
  name_prefix          = "production-worker-node"
  security_groups      = ["${aws_security_group.prod-worker-node-sg.id}"]
  user_data_base64     = "${base64encode(local.worker-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

#Autoscalling Group
resource "aws_autoscaling_group" "production-worker" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.worker.id}"
  max_size             = 3
  min_size             = 2
  name                 = "production-worker-nodes"
  vpc_zone_identifier  = ["${var.prod_worker_subnet}"]

  tag {
    key                 = "Name"
    value               = "production-worker-nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster-name}"
    value               = ""
    propagate_at_launch = true
  }
}