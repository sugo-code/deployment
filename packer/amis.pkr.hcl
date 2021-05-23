locals {
  name_prefix = "clod2021-group2-ami"
  source_ami = "ami-063d4ab14480ac177"
  region = "eu-west-1"
  subnet_id = "subnet-07665accf656cdefc"
}

#TODO: Use docker instead of two different images

source "amazon-ebs" "nodejs" {
  ami_name      = "${local.name_prefix}-nodejs"
  instance_type = "t2.micro"

  region    = local.region
  subnet_id = local.subnet_id
  associate_public_ip_address = true

  source_ami = local.source_ami
  ssh_username = "ec2-user"

}

source "amazon-ebs" "influxdb" {
  ami_name      = "${local.name_prefix}-influxdb"
  instance_type = "t2.micro"

  region    = local.region
  subnet_id = local.subnet_id
  associate_public_ip_address = true

  source_ami = local.source_ami
  ssh_username = "ec2-user"

}

build {
  sources = [
    "source.amazon-ebs.nodejs",
    "source.amazon-ebs.influxdb"
  ]

  provisioner "shell" {
    except = ["amazon-ebs.influxdb"]
    script = "codedeploy.sh"
  }

  provisioner "shell" {
    only = ["amazon-ebs.nodejs"]
    script = "nodejs.sh"
  }

  provisioner "shell" {
    only = ["amazon-ebs.influxdb"]
    script = "influxdb.sh"
  }
}
