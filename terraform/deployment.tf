# Create service roles

resource "aws_iam_role" "codebuild" {
  name = "${var.prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
            Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "codedeploy" {
  name = "${var.prefix}-codedeploy-role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Effect = "Allow"
        Principal = {
          Service = [
            "codedeploy.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "${var.prefix}-codedeploy-autoscaling-group-additional-permissions-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:RunInstances",
            "ec2:CreateTags",
            "iam:PassRole"
          ]
          Resource = "*"
        }
      ]
    })
  } 
}

# Create the deployment apps

# resource "aws_codedeploy_app" "auth_api" {
#   name = "${var.prefix}-auth-api"
# }

# resource "aws_codedeploy_app" "data_api" {
#   name = "${var.prefix}-data-api"
# }

# resource "aws_codedeploy_app" "realtime_api" {
#   name = "${var.prefix}-realtime-api"
# }

# resource "aws_codedeploy_app" "alarms_api" {
#   name = "${var.prefix}-alarms-api"
# }

resource "aws_codedeploy_app" "api_gateway" {
  name = "${var.prefix}-api-gateway"
}

# Create the deployment groups

# resource "aws_codedeploy_deployment_group" "auth_api" {
#   app_name = aws_codedeploy_app.auth_api.name
#   deployment_group_name = "${var.prefix}-deployment-group-auth-api"
#   service_role_arn = aws_iam_role.codedeploy.arn

#   ec2_tag_filter {
#     key = "Name"
#     type = "KEY_AND_VALUE"
#     value = "${var.prefix}-auth-api"
#   }

#   #autoscaling_groups = [aws_autoscaling_group.auth_api.id]
# }

# resource "aws_codedeploy_deployment_group" "data_api" {
#   app_name = aws_codedeploy_app.data_api.name
#   deployment_group_name = "${var.prefix}-deployment-group-data-api"
#   service_role_arn = aws_iam_role.codedeploy.arn

#   ec2_tag_filter {
#     key = "Name"
#     type = "KEY_AND_VALUE"
#     value = "${var.prefix}-data-api"
#   }
# }

# resource "aws_codedeploy_deployment_group" "realtime_api" {
#   app_name = aws_codedeploy_app.realtime_api.name
#   deployment_group_name = "${var.prefix}-deployment-group-realtime-api"
#   service_role_arn = aws_iam_role.codedeploy.arn

#   ec2_tag_filter {
#     key = "Name"
#     type = "KEY_AND_VALUE"
#     value = "${var.prefix}-realtime-api"
#   }
# }

# resource "aws_codedeploy_deployment_group" "alarms_api" {
#   app_name = aws_codedeploy_app.alarms_api.name
#   deployment_group_name = "${var.prefix}-deployment-group-alarms-api"
#   service_role_arn = aws_iam_role.codedeploy.arn

#   ec2_tag_filter {
#     key = "Name"
#     type = "KEY_AND_VALUE"
#     value = "${var.prefix}-alarms-api"
#   }
# }

resource "aws_codedeploy_deployment_group" "api_gateway" {
  app_name = aws_codedeploy_app.api_gateway.name
  deployment_group_name = "${var.prefix}-deployment-group-api-gateway"
  service_role_arn = aws_iam_role.codedeploy.arn

  ec2_tag_filter {
    key = "Name"
    type = "KEY_AND_VALUE"
    value = "${var.prefix}-api-gateway"
  }
}

resource "aws_s3_bucket" "secrets" {
  bucket = "${var.prefix}-bucket-secrets"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "api_gateway_secrets" {
  key    = "api-gateway/.env"
  bucket = aws_s3_bucket.secrets.id
 
  content = <<EOT
    DATA_API_URL=http://test
    AUTH_API_URL=http://test2
    REALTIME_API_URL=http://test3
    EOT

  # content = <<EOT
  #   DATA_API_URL=http://${aws_instance.data_api.private_dns}
  #   AUTH_API_URL=http://${aws_instance.auth_api.private_dns}
  #   REALTIME_API_URL=http://${aws_instance.realtime_api.private_dns}
  #   EOT
}

resource "aws_s3_bucket_object" "realtime_api_secrets" {
  key    = "realtime-api/.env"
  bucket = aws_s3_bucket.secrets.id
 
  #TODO: Add env vars
  content = <<EOT
    RABBITMQ_URL=ampqs://
    EOT
}

resource "aws_s3_bucket_object" "auth_api_secrets" {
  key    = "auth-api/.env"
  bucket = aws_s3_bucket.secrets.id
 
  #TODO: Add env vars
  content = <<EOT
    MONGO_URI=
    MONGO_DB=
    RABBITMQ_URL=
    JWT_SECRET=
    EOT
}

resource "aws_s3_bucket_object" "alarms_api_secrets" {
  key    = "alarms-api/.env"
  bucket = aws_s3_bucket.secrets.id
 
  #TODO: Add env vars
  content = <<EOT
    VONAGE_API_KEY=
    VONAGE_API_SECRET=
    RABBITMQ_URL=
    EOT
}

resource "aws_s3_bucket_object" "data_api_secrets" {
  key    = "data-api/.env"
  bucket = aws_s3_bucket.secrets.id
 
  #TODO: Add env vars
  content = <<EOT
    POSTGRESQL_URL=
    INFLUXDB_URL=
    INFLUXDB_ORG=
    INFLUXDB_TOKEN=
    INFLUXDB_BUCKET=
    RABBITMQ_URL=
    EOT
}
