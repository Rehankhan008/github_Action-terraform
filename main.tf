# Security Group for EC2
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create two EC2 instances in different AZs
resource "aws_instance" "web_servers" {
  ami           = "ami-053b12d3152c0cc71" # Replace with the correct Ubuntu 24.04 LTS AMI ID for your region
  instance_type = "t2.micro"
  key_name      = "mum-key" # Use your existing key pair

  # Assign subnets based on count
  subnet_id = "subnet-04a6a3611a6dff5d8"


  # Associate the security group created
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]

  # Install Docker on the instance
  user_data = <<-EOF
              #!/bin/bash
              # Update and install dependencies
              sudo apt-get update -y
              
              sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

              # Add Docker GPG key
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

              # Add Docker APT repository
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
              sudo apt-cache policy docker-ce 
              sudo apt install docker-ce -y
              sudo systemctl status docker
              sudo usermod -aG docker ubuntu
              newgrp docker
              EOF

  tags = {
    Name = "WebServer"
  }
}

# Output the Public IPs of both instances
output "instance_ips" {
  value = aws_instance.web_servers[*].public_ip
}
