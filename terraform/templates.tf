locals {
  ami_prefix             = "${var.prefix}-ami"
  launch_template_prefix = "${var.prefix}-launch-template"
  security_group_prefix  = "${var.prefix}-security-group"
}

data "aws_ami" "influxdb" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-influxdb*"]
  }
}

data "aws_ami" "nodejs" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-nodejs*"]
  }
}

resource "aws_security_group" "main" {
  name        = "${local.security_group_prefix}-main"
  description = "Allow All outbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "http" {
  name        = "${local.security_group_prefix}-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 0
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "influxdb_http" {
  name        = "${local.security_group_prefix}-influxdb-http"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP (port 8096)"
    from_port        = 0
    to_port          = 8096
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_launch_template" "nodejs" {
  name     = "${local.launch_template_prefix}-nodejs"
  image_id = data.aws_ami.nodejs.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.main.id,
    aws_security_group.http.id
  ]
}

resource "aws_launch_template" "influxdb" {
  name     = "${local.launch_template_prefix}-influxdb"
  image_id = data.aws_ami.influxdb.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.main.id,
    aws_security_group.influxdb_http.id
  ]
}
