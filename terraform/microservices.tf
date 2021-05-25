# Terraform Aws provider does not support launch templates for ec2 instances
# Also, it is not able to get ips of machines created by an autoscaling groups

# resource "aws_autoscaling_group" "auth_api" {
#   name               = "${var.prefix}-auth-api"
#   desired_capacity   = 1
#   max_size           = 1
#   min_size           = 1

#   vpc_zone_identifier = [aws_subnet.private.id]

#   launch_template {
#     id      = aws_launch_template.nodejs.id
#     version = "$Latest"
#   }
# }

# Frontend

resource "aws_s3_bucket" "web_app" {
  bucket = "${var.prefix}-bucket-web-app"
  acl    = "public-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.prefix}-bucket-web-app/*"
        ]
      }
    ]
  })

  website {
    index_document = "index.html"
  }
}

# APIs

# resource "aws_instance" "auth_api" {
#   ami = aws_launch_template.nodejs.image_id
#   instance_type = aws_launch_template.nodejs.instance_type

#   security_groups = aws_launch_template.nodejs.security_group_names
#   subnet_id = aws_subnet.private.id

#   tags = {
#     Name = "${var.prefix}-auth-api"
#   }
# }

# resource "aws_instance" "data_api" {
#   ami = aws_launch_template.nodejs.image_id
#   instance_type = aws_launch_template.nodejs.instance_type

#   security_groups = aws_launch_template.nodejs.security_group_names
#   subnet_id = aws_subnet.private.id

#   tags = {
#     Name = "${var.prefix}-data-api"
#   }
# }

# resource "aws_instance" "realtime_api" {
#   ami = aws_launch_template.nodejs.image_id
#   instance_type = aws_launch_template.nodejs.instance_type

#   security_groups = aws_launch_template.nodejs.security_group_names
#   subnet_id = aws_subnet.private.id

#   tags = {
#     Name = "${var.prefix}-realtime-api"
#   }
# }

# resource "aws_instance" "alarms_api" {
#   ami = aws_launch_template.nodejs.image_id
#   instance_type = aws_launch_template.nodejs.instance_type

#   security_groups = aws_launch_template.nodejs.security_group_names
#   subnet_id = aws_subnet.private.id

#   tags = {
#     Name = "${var.prefix}-alarms-api"
#   }
# }

# Gateway

resource "aws_instance" "api_gateway" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  security_groups = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.public.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = var.ssh_key_name

  tags = {
    Name = "${var.prefix}-api-gateway"
  }
}

# Message Bus

# Missing permission mq:CreateBroker
# resource "aws_mq_broker" "message_bus" {
#   broker_name = "${var.prefix}-message-bus"

#   engine_type        = "RabbitMQ"
#   engine_version     = "3.8.11"
#   host_instance_type = "mq.t2.micro"

#   user {
#     username = "test"
#     password = "testtesttest"
#   }
# }

# Databases

#TODO: Specify VPC
#TODO: If using docker add command to install and start influxdb and use port 80
# resource "aws_instance" "data_db" {
#   ami = aws_launch_template.influxdb.image_id
#   instance_type = aws_launch_template.influxdb.instance_type

#   security_groups = aws_launch_template.influxdb.security_group_names
#   subnet_id = aws_subnet.private.id

#   tags = {
#     Name = "${var.prefix}-data-db"
#   }
# }

#TODO: Specify VPC
# resource "aws_db_instance" "parameters_db" {
#   identifier = "${var.prefix}-parameters-db"

#   allocated_storage    = 5
#   engine               = "postgresql"
#   engine_version       = "13.1"
#   instance_class       = "db.t3.micro"

#   name                 = "db"
#   username             = "test"
#   password             = "testtest"

#   skip_final_snapshot  = true
# }

# hostname is undefined on the connection string??
# This happens because docdb needs a vpc with 3 availability zones (will probably use docker-compose)

#TODO: Specify VPC
# resource "aws_docdb_cluster" "auth_db" {
#   cluster_identifier      = "${var.prefix}-auth-db"
#   engine                  = "docdb"

#   master_username         = "test"
#   master_password         = "testtest"

#   skip_final_snapshot     = true
# }
