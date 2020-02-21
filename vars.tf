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
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
  default     = "t3.micro"
}

variable instance_name {
  type        = string
  description = "A name to attach to the EC2 instance."
  default     = "wireguard-vpn-node"
}

variable mgmt_allowed_hosts {
  type        = list
  description = "A list of hosts/networks to open up SSH access to."
  default     = []
}

variable sg_wg_allowed_subnets {
  type        = list
  description = "A list of hosts/networks to open up WireGuard access to."
  default     = ["0.0.0.0/0"]
}

variable "ssh_public_key" {
  type        = string
  description = "(Optional) A SSH public key to create a key pair for in AWS EC2."
  default     = null
}


# DNS
variable dns_zone {
  type        = string
  description = "(Optional) The Route53 hosted zone to add DNS records to."
  default     = null
}

variable dns_fqdn {
  type        = string
  description = "(Optional) The FQDN of the A record pointing to the EC2 instance."
  default     = null
}

# Wireguard
variable wg_client_public_keys {
  type        = map(map(string))
  description = "List of maps of client IPs and public keys. See Usage in README for details."
}

variable "wg_persistent_keepalive" {
  type        = number
  description = "Persistent Keepalive - useful for helping connectiona stability over NATs"
  default     = 25
}

variable wg_server_network_cidr {
  type        = string
  description = "The internal network to use for WireGuard. Remember to place the clients in the same subnet."
  default     = "192.168.2.0/24"
}

variable "wg_server_port" {
  type        = number
  description = "The port WireGuard should listen on."
  default     = 51820
}

variable wg_privkey_ssm_path {
  type        = string
  description = "The path to the WireGuard server's private key in SSM"
}
