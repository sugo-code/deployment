locals {
  ami_prefix             = "${var.prefix}-ami"
  launch_template_prefix = "${var.prefix}-launch-template"
  security_group_prefix  = "${var.prefix}-security-group"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "influxdb" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-influxdb*"]
  }
}

data "aws_ami" "docker" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-docker*"]
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

resource "aws_security_group" "ssh" {
  name        = "${local.security_group_prefix}-ssh"
  description = "Allow All outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
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
    from_port        = 80
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
    description      = "InfluxDB"
    from_port        = 8086
    to_port          = 8086
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "amqp" {
  name        = "${local.security_group_prefix}-amqp"
  description = "Allow AMQP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "AMQP"
    from_port        = 5671
    to_port          = 5671
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "postgresql" {
  name        = "${local.security_group_prefix}-postgresql"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "PostgreSQL"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "mongodb" {
  name        = "${local.security_group_prefix}-mongodb"
  description = "Allow MongoDB inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "MongoDB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "amazonmq-console" {
  name        = "${local.security_group_prefix}-amazonmq-console"
  description = "Allow AMQP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Amazon MQ web console"
    from_port        = 8162
    to_port          = 8162
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_role" "ec2_instance_profile" {
  name = "${var.prefix}-ec2-instance-profile"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "${var.prefix}-ec2-instance-profile-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:Get*",
            "s3:List*"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_profile.name
}

resource "aws_launch_template" "docker" {
  name     = "${local.launch_template_prefix}-docker"
  image_id = data.aws_ami.docker.id

  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.main.id,
    aws_security_group.http.id,
    aws_security_group.ssh.id
  ]
}

resource "aws_launch_template" "influxdb" {
  name     = "${local.launch_template_prefix}-influxdb"
  image_id = data.aws_ami.influxdb.id

  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.main.id,
    aws_security_group.ssh.id,
    aws_security_group.influxdb_http.id
  ]

  user_data = base64encode(<<EOF
    #!/bin/bash
    until curl http://localhost:8086/ping
    do
      sleep 1
    done
    influx setup -u ${var.influxdb_username} -p ${var.influxdb_password} -t ${var.influxdb_token} -o ${var.influxdb_organization} -b ${var.influxdb_bucket} -r 1w -f
    EOF
  )
}
