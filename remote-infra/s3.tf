resource "aws_s3_bucket" "remote-backend-bucket" {
  bucket        = "remote-backend-bucket-for-storing-statefile"
  force_destroy = true

  tags = {
    Name = "remote-backend-bucket"
  }
}