resource "aws_dynamodb_table" "remote-backend-table" {
  name         = "${var.env}-remote-backend-table"
  billing_mode = "PAY_PER_REQUEST" # pay as you go mode will be enabled on this table
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  tags = {
    Name = "${var.env}-remote-backend-table"
  }
}