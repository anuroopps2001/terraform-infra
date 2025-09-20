locals {
  bucket_name = format("%s-%s-%s", lower("${var.env}-infra-app-bucket"), data.aws_region.current.id, data.aws_caller_identity.current.account_id)
}

resource "aws_s3_bucket" "this-bucket" {
  bucket = local.bucket_name

  tags = {
    Name = local.bucket_name
  }
}