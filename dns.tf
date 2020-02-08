resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.dns_fqdn
  type    = "A"
  ttl     = "30"
  records = [
    aws_eip.main.public_ip
  ]
}
