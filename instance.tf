resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  key_name = var.ssh_public_key != null ? aws_key_pair.main.0.key_name : null

  associate_public_ip_address = true

  subnet_id = data.aws_subnet.main.0.id

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  iam_instance_profile = aws_iam_instance_profile.main.name

  user_data_base64 = base64encode(data.template_file.user_data.rendered)
}

resource "aws_eip" "main" {
  vpc = true

  tags = var.tags
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main.id
}
