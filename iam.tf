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

resource "aws_iam_role" "main" {
  name               = var.instance_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.tags
}

resource "aws_iam_instance_profile" "main" {
  name = "vpn_node"
  role = aws_iam_role.main.name
}

data "aws_iam_policy_document" "main" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [data.aws_ssm_parameter.wg_private_key.arn]
  }

  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:ListAssociations",
      "ssm:GetDocument",
      "ssm:ListInstanceAssociations",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceInformation",

      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",

      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "main" {
  name   = var.instance_name
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
