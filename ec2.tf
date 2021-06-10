#............. Provider.................

provider "aws" {
  region  = "us-east-1"
}

#................latest ubuntu AMI.............

resource "aws_s3_bucket" "b" {
  bucket = "192.16.134.22"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
