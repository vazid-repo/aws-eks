#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

#IAM Role
resource "aws_iam_role" "prod-cluster-role" {
  name = "voice-services-production-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "prod-eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.prod-cluster-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.prod-cluster-role.name}"
}

resource "aws_iam_role_policy_attachment" "prod-eks-cluster-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = "${aws_iam_role.prod-cluster-role.name}"
}

#Security Group
resource "aws_security_group" "prod-cluster-sg" {
  name        = "voice-services-production-clusterSG"
  description = "Cluster communication with production worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "Voice-services-production-cluster"
    Enviorment = "Production"
  }
}

resource "aws_security_group_rule" "prod-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the production cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.prod-cluster-sg.id}"
  source_security_group_id = "${aws_security_group.prod-worker-node-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "prod-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the production cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.prod-cluster-sg.id}"
  to_port           = 443
  type              = "ingress"
}

#EKS Service
resource "aws_eks_cluster" "eks-prod-cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.prod-cluster-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.prod-cluster-sg.id}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.prod-eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.prod-eks-cluster-AmazonEKSServicePolicy",
  ]
}
