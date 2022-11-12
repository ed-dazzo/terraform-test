# Database layer for the web app

#
# Database layer
#

resource "aws_dynamodb_table" "main" {
  name           = "web-app-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = "30"
  write_capacity = "30"
  hash_key       = "app"
  lifecycle {
    ignore_changes = [
      write_capacity, read_capacity
    ]
  }
  attribute {
    name = "app"
    type = "S"
  }
}

# Since the database only stores one item, and dynamodb
# won't be backed up, we recreate the key when the
# configuration is applied
resource "aws_dynamodb_table_item" "main" {
  table_name = aws_dynamodb_table.main.name
  hash_key   = aws_dynamodb_table.main.hash_key

  item = <<ITEM
{
  "app": {"S": "${local.name}"},
  "message": {"S": "Hello World"}
}
ITEM
}
