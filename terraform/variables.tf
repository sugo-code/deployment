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

variable "elastic_ip_id" {
  type = string
  description = "AWS elastic ip id, used in the NAT Gateway, to allow machines in the private subnet to access the internet"
  sensitive = true
}
