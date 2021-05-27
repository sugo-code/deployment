variable "region" {
  type = string
  description = "AWS region"
  default = "eu-west-1"
}

variable "prefix" {
  type = string
  description = "AWS naming prefix"
  default = "clod2021-group2"
}

# The School's AWS account has already assigned 5 elastic ips, which is the maximum amount.
# Instead of creating a new elastic ip, an already existing one will be used
variable "elastic_ip_id" {
  type = string
  description = "AWS elastic ip id, used in the NAT Gateway, to allow machines in the private subnet to access the internet"
  sensitive = true
}

variable "rabbitmq_username" {
  type = string
  sensitive = true
}

variable "rabbitmq_password" {
  type = string
  sensitive = true
}

variable "influxdb_username" {
  type = string
  sensitive = true
}
variable "influxdb_password" {
  type = string
  sensitive = true
}

variable "influxdb_token" {
  type = string
  sensitive = true
}

variable "influxdb_organization" {
  type = string
  sensitive = true
}

variable "influxdb_bucket" {
  type = string
  sensitive = true
}

variable "postgresql_username" {
  type = string
  sensitive = true
}

variable "postgresql_password" {
  type = string
  sensitive = true
}

variable "postgresql_database" {
  type = string
  sensitive = true
}

variable "mongodb_username" {
  type = string
  sensitive = true
}

variable "mongodb_password" {
  type = string
  sensitive = true
}

variable "mongodb_database" {
  type = string
  sensitive = true
}

variable "jwt_encryption_secret" {
  type = string
  sensitive = true
}

variable "vonage_api_key" {
  type = string
  sensitive = true
}

variable "vonage_api_secret" {
  type = string
  sensitive = true
}
