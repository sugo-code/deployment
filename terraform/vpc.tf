locals {
  vpc_cidr_block = "10.0.0.0/16"
  public_cidr_block = "10.0.0.0/24"
  private_cidr_block = "10.0.1.0/24"
}

# Define the VPC

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Add public and private subnets

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr_block

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr_block

  tags = {
    Name = "${var.prefix}-subnet-private"
  }
}

# Define an internet gateway, to allow machines in the public subnets to be reached from the internet (two-way)

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

# Define a nat gateway, to allow machines in the private subnet to reach the internet (one-way)

resource "aws_nat_gateway" "main" {
  allocation_id = var.elastic_ip_id
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "${var.prefix}-nat-gateway"
  }
}

# Add routing tables

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.prefix}-route-table"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.prefix}-route-table-public"
  }
}

# Link the subnets to the appropriate routing tables

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}
