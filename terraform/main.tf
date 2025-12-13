terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Security Group to allow Web (80) and SSH (22)
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# The EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-04b4f1a9cf54c11d0" # Ubuntu 20.04 LTS (US-East-1) check for updates if needed
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # This script runs on startup to install Docker and run your app
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker pull sheltonmacamo7/card-game:latest
              sudo docker run -d -p 80:5000 sheltonmacamo7/card-game:latest
              EOF

  tags = {
    Name = "DevOps-Card-Game-Server"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}