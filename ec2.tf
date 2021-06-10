#............. Provider.................

provider "aws" {
  region  = "us-east-1"
}

#................latest ubuntu AMI.............

 #................latest ubuntu AMI.............

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#.............ubuntu server.................

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  ebs_optimized     = true
  instance_type = "t3.micro"
  
  metadata_options {
     http_endpoint = "enabled"
     http_tokens   = "required"
 }

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_ebs_encryption_by_default" "example" {
  enabled = true
}
