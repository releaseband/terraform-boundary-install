
resource "aws_iam_access_key" "boundary_access_key" {
  user = aws_iam_user.boundary_iam_user.name
}


resource "aws_iam_user" "boundary_iam_user" {
  name = "boundary"
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name = "boundary"
  user = aws_iam_user.boundary_iam_user.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
{
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
