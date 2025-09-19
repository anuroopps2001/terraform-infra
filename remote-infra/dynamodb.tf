resource "aws_dynamodb_table" "remote-backend-table" {
  name         = "remote-backend-table"
  billing_mode = "PAY_PER_REQUEST" # pay as you go mode will be enabled on this table
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "remote-backend-table"
  }
}