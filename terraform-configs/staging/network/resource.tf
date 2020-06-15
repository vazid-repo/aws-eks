#Subnets 
#Staging Public Subnet
# VPC Elastic IP

data "aws_availability_zones" "available" {}

resource "aws_subnet" "staging_public_subnet" {
  count             = "${length(var.staging_public_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.staging_public_subnet_cidr[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
    "Name", "staging_public_subnet_${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}" , "owned",
    "kubernetes.io/role/elb" , "1",
    )
  }"
}

#Staging Private Subnet
resource "aws_subnet" "staging_private_subnet" {
  count             = "${length(var.staging_private_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.staging_private_subnet_cidr[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
    "Name", "staging_private_subnet_${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}" , "owned",
    "kubernetes.io/role/internal-elb" , "1",
    )
  }"
}

#EKS Kubernetes Subnet

resource "aws_subnet" "staging_rds_subnet" {
  count             = "${length(var.staging_rds_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.staging_rds_subnet_cidr, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Staging-rds_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "staging_master_subnet" {
  count             = "${length(var.staging_master_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.staging_master_subnet_cidr, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Staging_Master_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

#Worker Nodes
resource "aws_subnet" "staging_worker_subnet" {
  count             = "${length(var.staging_worker_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.staging_worker_subnet_cidr,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Staging_Worker_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

#Public Route Table
resource "aws_route_table" "rt_public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.internet_gateway}"
  }

  tags = {
    Name = "rt_public"
  }
}

#Public Route Table Association

resource "aws_route_table_association" "staging_master" {
  count          = "${length(var.staging_master_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.staging_master_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_public.id}"
}


resource "aws_route_table_association" "staging_public" {
  count          = "${length(var.staging_public_subnet_cidr)}"
  subnet_id      = "${aws_subnet.staging_public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

#VPC Elastic IP
resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "staging_vernacular_eip"
  }
}

#NatGatways
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${element(aws_subnet.staging_master_subnet.*.id, count.index)}"

  tags {
    Name = "staging_vernacular_nat"
  }
}

#Private Route Table

resource "aws_route_table" "rt_private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }

  tags {
    Name = "rt_private"
  }
}

# Private Route Table Association 
resource "aws_route_table_association" "stagingdb" {
  count          = "${length(var.staging_rds_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.staging_rds_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_route_table_association" "staging_worker" {
  count          = "${length(var.staging_worker_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.staging_worker_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_route_table_association" "private_subnet" {
  count          = "${length(var.staging_private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.staging_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}
