output vpn_node_fqdn {
  description = "The FQDN of the EC2 instance."
  value       = var.dns_fqdn != null ? var.dns_fqdn : null
}

output vpn_node_public_ip {
  description = "The public IP of the EC2 instance."
  value       = aws_instance.main.public_ip
}