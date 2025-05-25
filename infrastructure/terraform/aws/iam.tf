resource "aws_iam_user" "iam_user" {
  name = "${var.project_name}-iam-user"
  path = "/"
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name = "${var.project_name}-iam-user-policy"
  user = aws_iam_user.iam_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem", "dynamodb:DeleteItem",
                    "dynamodb:BatchGetItem", "dynamodb:BatchWriteItem", ]
        Resource = "*"
      }
    ]
  })
}