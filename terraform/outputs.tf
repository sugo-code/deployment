output "service_private_key" {
  value = tls_private_key.service_key.private_key_pem
  sensitive = true
}

# output "web_app_cdn_endpoint" {
#   value = aws_cloudfront_distribution.web_app.domain_name
# }

output "web_app_bucket_endpoint" {
  value = aws_s3_bucket.web_app.website_endpoint
}

# output "api_gateway_load_balancer_endpoint" {
#   value = aws_lb.api_gateway.dns_name
# }

output "api_gateway_instance_endpoint" {
  value = aws_instance.api_gateway.public_dns
}

output "web_app_bucket" {
  value = aws_s3_bucket.web_app.bucket
}

output "auth_api_codedeploy_app" {
  value = aws_codedeploy_app.auth_api.name
}

output "auth_api_codedeploy_group" {
  value = aws_codedeploy_deployment_group.auth_api.deployment_group_name
}

output "data_api_codedeploy_app" {
  value = aws_codedeploy_app.data_api.name
}

output "data_api_codedeploy_group" {
  value = aws_codedeploy_deployment_group.data_api.deployment_group_name
}

output "realtime_api_codedeploy_app" {
  value = aws_codedeploy_app.realtime_api.name
}

output "realtime_api_codedeploy_group" {
  value = aws_codedeploy_deployment_group.realtime_api.deployment_group_name
}

output "alarms_api_codedeploy_app" {
  value = aws_codedeploy_app.alarms_api.name
}

output "alarms_api_codedeploy_group" {
  value = aws_codedeploy_deployment_group.alarms_api.deployment_group_name
}

output "api_gateway_public_dns" {
  value = aws_instance.api_gateway.public_dns
}

output "api_gateway_codedeploy_app" {
  value = aws_codedeploy_app.api_gateway.name
}

output "api_gateway_codedeploy_group" {
  value = aws_codedeploy_deployment_group.api_gateway.deployment_group_name
}
