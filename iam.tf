data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vpn_node_policy_doc" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [data.aws_ssm_parameter.wg_private_key.arn]
  }
}

resource "aws_iam_policy" "main" {
  name   = var.instance_name
  policy = data.aws_iam_policy_document.vpn_node_policy_doc.json
}

resource "aws_iam_role" "main" {
  name               = var.instance_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}



resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_instance_profile" "main" {
  name = "vpn_node"
  role = aws_iam_role.main.name
}
