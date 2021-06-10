#............. Provider.................

provider "aws" {
  region  = "us-east-1"
}

#................latest ubuntu AMI.............

resource "aws_s3_bucket" "b" {
  bucket = "192.16.134.22."
  acl    = "private"
  
  logging {
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
  }
}

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
