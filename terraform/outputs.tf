output "web_app_bucket" {
  value = aws_s3_bucket.web_app.bucket
}

output "auth_api_private_dns" {
  value = aws_instance.auth_api.private_dns
}

output "auth_api_codedeploy_app" {
  value = aws_codedeploy_app.auth_api.name
}

output "auth_api_codedeploy_group" {
  value = aws_codedeploy_deployment_group.auth_api.deployment_group_name
}

# output "data_api_private_dns" {
#   value = aws_instance.data_api.private_dns
# }

# output "data_api_codedeploy_app" {
#   value = aws_codedeploy_app.data_api.name
# }

# output "data_api_codedeploy_group" {
#   value = aws_codedeploy_deployment_group.data_api.deployment_group_name
# }

# output "realtime_api_private_dns" {
#   value = aws_instance.realtime_api.private_dns
# }

# output "realtime_api_codedeploy_app" {
#   value = aws_codedeploy_app.realtime_api.name
# }

# output "realtime_api_codedeploy_group" {
#   value = aws_codedeploy_deployment_group.realtime_api.deployment_group_name
# }

# output "alarms_api_private_dns" {
#   value = aws_instance.alarms_api.private_dns
# }

# output "alarms_api_codedeploy_app" {
#   value = aws_codedeploy_app.alarms_api.name
# }

# output "alarms_api_codedeploy_group" {
#   value = aws_codedeploy_deployment_group.alarms_api.deployment_group_name
# }

# output "api_gateway_private_dns" {
#   value = aws_instance.api_gateway.private_dns
# }

# output "api_gateway_codedeploy_app" {
#   value = aws_codedeploy_app.api_gateway.name
# }

# output "api_gateway_codedeploy_group" {
#   value = aws_codedeploy_deployment_group.api_gateway.deployment_group_name
# }
