terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "user1"
  monitoring             = true
  subnet_id              = "subnet-eddcdzz4"
  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name        = "single-instance"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "example" {
  name        = "ec2-example-sg"
  description = "Allow SSH and HTTP for EC2 instance"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-example-sg"
  }
}

data "aws_subnet" "selected" {
  id = "subnet-eddcdzz4"
}