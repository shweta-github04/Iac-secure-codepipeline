
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
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_acl" "acl_ok" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.my_subnet.id]
}

resource "aws_network_interface" "network_interface_ok" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

#...........Ec2 server.............

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

#..........default Security group.........

#resource "aws_default_security_group" "default" {
#  vpc_id = aws_vpc.my_vpc.id
#}

resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  ebs_optimized     = true
  monitoring        = true
  instance_type     = "t3.micro"

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
#......VPC FLOW LOG..........#

data "template_file" "assume_role_policy" {
  template = file("${path.module}/assume_role_policy.json")
}

data "template_file" "log_policy" {
  template = file("${path.module}/log_policy.json")
}

resource "aws_iam_role" "iam_log_role" {
  name = "test"
  assume_role_policy = data.template_file.assume_role_policy.rendered
}

resource "aws_iam_role_policy" "log_policy" {
  name = "test"
  role = aws_iam_role.iam_log_role.id
  policy = data.template_file.log_policy.rendered
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "test"
  retention_in_days = 90
}

resource "aws_flow_log" "vpc_flow_log" {
  log_group_name = aws_cloudwatch_log_group.flow_log_group.name
  iam_role_arn   = aws_iam_role.iam_log_role.arn
  vpc_id         = aws_vpc.my_vpc.id
  traffic_type   = "ALL"
}
