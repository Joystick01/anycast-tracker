resource "aws_dynamodb_table" "aws_dynamodb_table_v4" {
  name = "${var.project_name}-dynamodb-table-v4"
  billing_mode = "PROVISIONED"
  read_capacity = 12
  write_capacity = 12
  hash_key = "id"
  range_key = "utctime"
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "utctime"
    type = "S"
  }
}

resource "aws_dynamodb_table" "aws_dynamodb_table_v6" {
  name = "${var.project_name}-dynamodb-table-v6"
  billing_mode = "PROVISIONED"
  read_capacity = 12
  write_capacity = 12
  hash_key = "id"
  range_key = "utctime"
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "utctime"
    type = "S"
  }
}

resource "aws_iam_user" "iam_user_dynamodb" {
  name = "${var.project_name}-iam-user"
  path = "/"
}

resource "aws_iam_access_key" "iam_access_key_dynamodb" {
  user = aws_iam_user.iam_user_dynamodb.name
}

resource "aws_iam_user_policy" "iam_user_policy_dynamodb" {
  name = "${var.project_name}-iam-user-policy"
  user = aws_iam_user.iam_user_dynamodb.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:BatchWriteItem" ]
        Resource = "*"
      }
    ]
  })
}