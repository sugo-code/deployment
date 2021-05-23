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
