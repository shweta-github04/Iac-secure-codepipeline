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
  ami               = data.aws_ami.ubuntu.id
  ebs_optimized     = true
  monitoring        = true
  instance_type     = "t3.micro"
  vpc_security_group_ids = ["sg-0676242cf7930910d"]
  subnet_id              = "subnet-053cc94194e1b9125"
  }
  
  metadata_options {
     http_endpoint = "enabled"
     http_tokens   = "required"
 }
  
  root_block_device {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 8
        volume_type           = "standard"  
  }

  tags = {
    Name = "HelloWorld"
  }
}

