# CodeDeploy when used with autoscaling groups based on launch templates needs additional permissions

# The school's account still has to add iam:DeletePolicy permission, for the time being an already existing one will be used

# resource "aws_iam_policy" "main" {
#   name = "${var.prefix}-codedeploy-role-policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:RunInstances",
#           "ec2:CreateTags",
#           "iam:PassRole"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# Create a CodeDeploy service role

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
    # Not needed with no autoscaling group "arn:aws:iam::240595528763:policy/clod2021-group2-codedeploy-role-policy", # TODO: replace with aws_iam_policy var when iam:DeletePolicy permission is added
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
}

# Create the deployment apps

resource "aws_codedeploy_app" "auth_api" {
  name = "${var.prefix}-auth-api"
}

# resource "aws_codedeploy_app" "data_api" {
#   name = "${var.prefix}-data-api"
# }

# resource "aws_codedeploy_app" "realtime_api" {
#   name = "${var.prefix}-realtime-api"
# }

# resource "aws_codedeploy_app" "alarms_api" {
#   name = "${var.prefix}-alarms-api"
# }

# resource "aws_codedeploy_app" "api_gateway" {
#   name = "${var.prefix}-api-gateway"
# }

# Create the deployment groups

resource "aws_codedeploy_deployment_group" "auth_api" {
  app_name = aws_codedeploy_app.auth_api.name
  deployment_group_name = "${var.prefix}-deployment-group-auth-api"
  service_role_arn = aws_iam_role.codedeploy.arn

  ec2_tag_filter {
    key = "Name"
    type = "KEY_AND_VALUE"
    value = "${var.prefix}-auth-api"
  }

  #autoscaling_groups = [aws_autoscaling_group.auth_api.id]
}

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

# resource "aws_codedeploy_deployment_group" "api_gateway" {
#   app_name = aws_codedeploy_app.api_gateway.name
#   deployment_group_name = "${var.prefix}-deployment-group-api-gateway"
#   service_role_arn = aws_iam_role.codedeploy.arn

#   ec2_tag_filter {
#     key = "Name"
#     type = "KEY_AND_VALUE"
#     value = "${var.prefix}-alarms-api"
#   }
# }
