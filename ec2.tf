
#............. Provider.................

provider "aws" {
  region  = "us-east-1"
}
#..............................

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_acl" "acl_ok" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.main.id]
}

resource "aws_network_interface" "network_interface_ok" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-005e54dee72cc1d00" # us-west-2
  ebs_optimized     = true
  monitoring        = true
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.network_interface_ok.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
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

}
