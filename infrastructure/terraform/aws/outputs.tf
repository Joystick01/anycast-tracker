output "AWS_ACCESS_KEY_ID" {
  value = aws_iam_access_key.iam_access_key.id
}

output "AWS_SECRET_ACCESS_KEY" {
  value     = nonsensitive(aws_iam_access_key.iam_access_key.secret)
}

output "AWS_DEFAULT_REGION" {
  value = "eu-central-1"
}

output "DYNAMODB_TABLE_V4" {
  value = aws_dynamodb_table.aws_dynamodb_table_v4.name
}

output "DYNAMODB_TABLE_V6" {
  value = aws_dynamodb_table.aws_dynamodb_table_v6.name
}