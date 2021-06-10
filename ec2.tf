#............. Provider.................

provider "aws" {
  region  = "us-east-1"
}

#................latest ubuntu AMI.............
resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-tf-log-bucket"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "test-tf-enc" {
  bucket = "test-tf-enc"
  acl    = "private"

  logging {
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
 }  
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


