resource "aws_key_pair" "main" {
  count = var.ssh_public_key != null ? 1 : 0

  key_name   = var.instance_name
  public_key = var.ssh_public_key
}
