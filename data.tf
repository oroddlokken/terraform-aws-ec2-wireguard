data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ssm_parameter" "wg_private_key" {
  # We want to check that it actually exists
  name            = var.wg_privkey_ssm_path
  with_decryption = false
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet" "main" {
  count  = length(var.aws_availability_zones)
  vpc_id = data.aws_vpc.main.id

  availability_zone = element(var.aws_availability_zones, count.index)

  default_for_az = true
}

data "aws_route53_zone" "main" {
  name         = var.dns_zone
  private_zone = false
}