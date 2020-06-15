#Subnets 
#Production Public Subnet

# VPC Elastic IP

data "aws_availability_zones" "available" {}

resource "aws_subnet" "prod_public_subnet" {
  count             = "${length(var.prod_public_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.prod_public_subnet_cidr[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
    "Name", "production_public_subnet_${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}" , "owned",
    "kubernetes.io/role/elb" , "1",
    )
  }"
}

#Production Private Subnet
resource "aws_subnet" "prod_private_subnet" {
  count             = "${length(var.prod_private_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.prod_private_subnet_cidr[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
    "Name", "production_private_subnet_${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster-name}" , "owned",
    "kubernetes.io/role/internal-elb" , "1",
    )
  }"
}

#EKS Kubernetes Subnet

resource "aws_subnet" "prod_rds_subnet" {
  count             = "${length(var.prod_rds_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.prod_rds_subnet_cidr, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Production-rds_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_subnet" "prod_master_subnet" {
  count             = "${length(var.prod_master_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.prod_master_subnet_cidr, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Production_Master_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

#Worker Nodes
resource "aws_subnet" "prod_worker_subnet" {
  count             = "${length(var.prod_worker_subnet_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.prod_worker_subnet_cidr,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "Production_Worker_${element(data.aws_availability_zones.available.names, count.index)}"
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

resource "aws_route_table_association" "prod_master" {
  count          = "${length(var.prod_master_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.prod_master_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

resource "aws_route_table_association" "production_public" {
  count          = "${length(var.prod_public_subnet_cidr)}"
  subnet_id      = "${aws_subnet.prod_public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.rt_public.id}"
}


#NatGatways
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${var.allocation_id}"
  subnet_id     = "${element(aws_subnet.prod_master_subnet.*.id, count.index)}"

  tags {
    Name = "vernacular_nat"
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
resource "aws_route_table_association" "proddb" {
  count          = "${length(var.prod_rds_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.prod_rds_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_route_table_association" "private_subnet" {
  count          = "${length(var.prod_private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.prod_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}

resource "aws_route_table_association" "prod_worker" {
  count          = "${length(var.prod_worker_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.prod_worker_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_private.id}"
}
