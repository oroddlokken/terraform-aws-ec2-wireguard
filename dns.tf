resource "aws_route53_record" "main" {
  count = var.dns_fqdn != null ? 1 : 0

  zone_id = data.aws_route53_zone.main.0.zone_id
  name    = var.dns_fqdn
  type    = "A"
  ttl     = "30"
  records = [
    aws_eip.main.public_ip
  ]
}
