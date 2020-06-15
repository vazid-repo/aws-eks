resource "aws_security_group" "staging-automation-server-instance-sg" {
  name        = "staging-automation-server-instance-sg"
  description = "staging_kubectl_instance_sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "test_staging_kubectl_server-SG"
  }
}

resource "aws_instance" "staging-automation-server" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.instance_ami}"
  key_name               = "${var.instance_key}"
  subnet_id              = "${var.k8-subnet}"
  vpc_security_group_ids = ["${aws_security_group.staging-automation-server-instance-sg.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y

#Install Kubectl

curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl
curl -o kubectl.sha256 https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl.sha256
openssl sha1 -sha256 kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH

#Install AWS IAM Authenticator

curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
curl -o aws-iam-authenticator.sha256 https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator.sha256
openssl sha1 -sha256 aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
aws-iam-authenticator help
EOF

  tags {
    Name = "Test Automation Server - Staging"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.staging-automation-server.id}"
  vpc      = true

  tags = {
    Name = "test_staging_server_eip"
  }
}
