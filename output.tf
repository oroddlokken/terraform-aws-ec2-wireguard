output vpn_node_fqdn {
  value = aws_route53_record.main.fqdn
}

output vpn_node_public_ip {
  value = aws_instance.main.public_ip
}