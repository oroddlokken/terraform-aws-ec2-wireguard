# Management
resource "aws_security_group" "main" {
  name        = var.instance_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = var.tags
}

resource "aws_security_group_rule" "incoming_mgmt" {
  count = length(var.mgmt_allowed_hosts) > 0 ? 1 : 0

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.mgmt_allowed_hosts

  security_group_id = aws_security_group.main.id
}

# WireGuard
resource "aws_security_group_rule" "incoming_wireguard" {
  type        = "ingress"
  from_port   = var.wg_server_port
  to_port     = var.wg_server_port
  protocol    = "udp"
  cidr_blocks = var.sg_wg_allowed_subnets

  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "internet_access_allow_ipv4" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main.id
}
