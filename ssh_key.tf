resource "aws_key_pair" "vpn_node" {
  key_name   = var.instance_name
  public_key = var.ssh_public_key
}