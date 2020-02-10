variable "aws_region" {
  description = "The AWS region to deploy resources in."
}

variable "aws_availability_zones" {
  type        = list(string)
  description = "The AWS availability zones to deploy resources in."
}

variable aws_account_id {
  description = "The AWS account ID this deployments belongs to."
}

variable tags {
  type        = map
  description = "A map with tags to attach to all created resources."
  default     = {}
}

# EC2
variable instance_type {
  type        = string
  default     = "t3.micro"
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable instance_name {
  type        = string
  default     = "wireguard-vpn-node"
  description = "A name to attach to the EC2 instance."
}

variable mgmt_allowed_hosts {
  type        = list
  default     = []
  description = "A list of hosts/networks to open up SSH access to."
}

variable sg_wg_allowed_subnets {
  type        = list
  default     = ["0.0.0.0/0"]
  description = "A list of hosts/networks to open up WireGuard access to."
}

variable "ssh_public_key" {
  type        = string
  default     = null
  description = "(Optional) A SSH public key to create a key pair for in AWS EC2."
}


# DNS
variable dns_zone {
  type        = string
  default     = null
  description = "(Optional) The Route53 hosted zone to add DNS records to."
}

variable dns_fqdn {
  type        = string
  default     = null
  description = "(Optional) The FQDN of the A record pointing to the EC2 instance."
}

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
  description = "The internal network to use for WireGuard. Remember to place the clients in the same subnet."
}

variable "wg_server_port" {
  default     = 51820
  description = "The port WireGuard should listen on."
}

variable wg_privkey_ssm_path {
  description = "The path to the WireGuard server's private key in SSM"
}
