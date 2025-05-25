resource "aws_dynamodb_table" "aws_dynamodb_table_v4" {
  name = "${var.project_name}-dynamodb-table-v4"
  billing_mode = "PROVISIONED"
  read_capacity = 12
  write_capacity = 12
  hash_key = "utctime"
  range_key = "region"
  attribute {
    name = "utctime"
    type = "S"
  }
  attribute {
    name = "region"
    type = "S"
  }
}

resource "aws_dynamodb_table" "aws_dynamodb_table_v6" {
  name = "${var.project_name}-dynamodb-table-v6"
  billing_mode = "PROVISIONED"
  read_capacity = 12
  write_capacity = 12
  hash_key = "utctime"
  range_key = "region"
  attribute {
    name = "utctime"
    type = "S"
  }
  attribute {
    name = "region"
    type = "S"
  }
}