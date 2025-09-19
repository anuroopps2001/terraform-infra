terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }

  # Locking .tfstate file with (s3+dynamodb)
  backend "s3" {
    bucket         = "remote-backend-bucket-for-storing-statefile"
    key            = "terraform.tfstate" # object name inside the bucket
    region         = "us-east-2"
    dynamodb_table = "remote-backend-table" # for state locking of tfstate file
  }
}

