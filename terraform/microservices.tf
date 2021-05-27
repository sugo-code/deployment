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
# resource "aws_cloudfront_distribution" "web_app" {
#   enabled = true
#   price_class = "PriceClass_100"

#   default_root_object = "index.html"

#   origin {
#     domain_name = aws_s3_bucket.web_app.website_endpoint
#     origin_id = "origin-bucket-${aws_s3_bucket.web_app.id}"

#     custom_origin_config {
#       origin_protocol_policy = "http-only"
#       http_port            = 80
#       https_port           = 443
#       origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
#     }
#   }


#   custom_error_response {
#     error_code    = 404
#     response_code = 200
#     response_page_path = "/index.html"
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "origin-bucket-${aws_s3_bucket.web_app.id}"

#     min_ttl = 0
#     default_ttl = 300
#     max_ttl = 1200

#     viewer_protocol_policy = "redirect-to-https"
#     compress = true

#     forwarded_values {
#       query_string = true
#       cookies {
#         forward = "all"
#       }
#     }

#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
# }

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
    error_document = "index.html"
  }

  force_destroy = true
}

# APIs
resource "aws_instance" "auth_api" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.private.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = aws_key_pair.service_key_pair.key_name

  tags = {
    Name = "${var.prefix}-auth-api"
  }
}

resource "aws_instance" "data_api" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.private.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = aws_key_pair.service_key_pair.key_name

  tags = {
    Name = "${var.prefix}-data-api"
  }
}

resource "aws_instance" "alarms_api" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.private.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = aws_key_pair.service_key_pair.key_name

  tags = {
    Name = "${var.prefix}-alarms-api"
  }
}

resource "aws_instance" "realtime_api" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.private.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = aws_key_pair.service_key_pair.key_name

  tags = {
    Name = "${var.prefix}-realtime-api"
  }
}

# Api Gateway
# resource "aws_lb" "api_gateway" {
#   name               = "${var.prefix}-api-gateway"
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]
#   security_groups = [ 
#     aws_security_group.main.id,
#     aws_security_group.https.id
#   ]
# }

# resource "aws_lb_target_group" "main" {
#   name     = "${var.prefix}-api-gateway"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
# }
# resource "aws_lb_target_group_attachment" "main" {
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = aws_instance.api_gateway.id
# }

# resource "aws_lb_listener" "main" {
#   load_balancer_arn = aws_lb.api_gateway.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_iam_server_certificate.main.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }

resource "aws_instance" "api_gateway" {
  ami = aws_launch_template.docker.image_id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = aws_launch_template.docker.vpc_security_group_ids
  subnet_id = aws_subnet.public.id

  iam_instance_profile = aws_launch_template.docker.iam_instance_profile[0].name

  key_name = aws_key_pair.service_key_pair.key_name

  tags = {
    Name = "${var.prefix}-api-gateway"
  }
}

# Message Bus
resource "aws_mq_broker" "message_bus" {
  broker_name = "${var.prefix}-message-bus"

  engine_type        = "RabbitMQ"
  engine_version     = "3.8.11"
  host_instance_type = "mq.t3.micro"

  subnet_ids = [aws_subnet.private.id]
  security_groups = [
    aws_security_group.amqp.id,
    aws_security_group.amazonmq-console.id,
    aws_security_group.main.id,
  ]

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }
}

# Databases

resource "aws_instance" "data_db" {
  ami = aws_launch_template.influxdb.image_id
  instance_type = aws_launch_template.influxdb.instance_type

  vpc_security_group_ids = aws_launch_template.influxdb.vpc_security_group_ids
  subnet_id = aws_subnet.private.id

  key_name = aws_key_pair.service_key_pair.key_name 
  tags = {
    Name = "${var.prefix}-data-db"
  }

  user_data = aws_launch_template.influxdb.user_data
}


resource "aws_db_subnet_group" "main" {
  name = "${var.prefix}-parameters-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
}

resource "aws_db_instance" "parameters_db" {
  identifier = "${var.prefix}-parameters-db"

  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "13.1"
  instance_class    = "db.t3.micro"

  name              = var.postgresql_database
  username          = var.postgresql_username
  password          = var.postgresql_password

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.postgresql.id, 
    aws_security_group.main.id
  ]

  skip_final_snapshot  = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}


resource "aws_docdb_subnet_group" "main" {
  name = "${var.prefix}-auth-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb3.6"
  name        = "${var.prefix}-auth-db-parameter-group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "auth_db" {
  cluster_identifier  = "${var.prefix}-auth-db"
  engine              = "docdb"
  engine_version      = "3.6.0"

  master_username     = var.mongodb_username
  master_password     = var.mongodb_password

  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  db_subnet_group_name = aws_docdb_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.mongodb.id, 
    aws_security_group.main.id
  ]

  skip_final_snapshot = true
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

resource "aws_docdb_cluster_instance" "auth_db" {
  count              = 1
  identifier         = "${var.prefix}-auth-db"
  cluster_identifier = aws_docdb_cluster.auth_db.id
  instance_class     = "db.t3.medium"
}
