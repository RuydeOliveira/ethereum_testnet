data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "ethereum-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

# Create the instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.instance_role.name
}

# Attach a managed policy
resource "aws_iam_role_policy_attachment" "ssm_session" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy" "dns_update" {
  name = "Allow_hosted_zone_update"
  role = aws_iam_role.instance_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = [aws_route53_zone.internal_zone.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones"
        ],
        Resource = ["*"]
      }
    ]
  })
}