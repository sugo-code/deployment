#TODO: add cloudwatch dashboards

resource "aws_cloudwatch_log_group" "auth_api" {
  name = "${var.prefix}-logs-auth-api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "data_api" {
  name = "${var.prefix}-logs-data-api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "realtime_api" {
  name = "${var.prefix}-logs-realtime-api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "alarms_api" {
  name = "${var.prefix}-logs-alarms-api"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "${var.prefix}-logs-api-gateway"
  retention_in_days = 30
}
