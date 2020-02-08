variable "aws_region" {
  description = "The AWS region to deploy in."
}

variable aws_account_id {
  description = "The AWS account ID this project belongs to."
}

variable "aws_availability_zones" {
  type = list(string)
}

# EC2
variable "ssh_public_key" {}

variable instance_type {
  default = "t3.micro"
}

variable instance_name {
  default = "wireguard-vpn-node"
}

variable mgmt_allowed_hosts {
  type = list
}

# DNS

variable dns_zone {}

variable dns_fqdn {}

# Wireguard

variable wg_client_public_keys {
  type        = map(map(string))
  description = "List of maps of client IPs and public keys. See Usage in README for details."
}

variable "wg_persistent_keepalive" {
  default     = 25
  description = "Persistent Keepalive - useful for helping connectiona stability over NATs"
}

variable wg_server_network_cidr {
  default     = "192.168.2.0/24"
  description = "The network to put the server in"
}

variable "wg_server_port" {
  default     = 51820
  description = "Port for the vpn server"
}

variable wg_privkey_ssm_path {
  description = "The path to the servers private key in SSM"
}
