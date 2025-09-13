provider "aws" {
  region = var.aws_region
  access_key = "your_access_key"      # replace with your access key
  secret_key = "your_secret_key"      # replace with your secret key
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

# 1 VPC & Subnet
resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-env"
  }
}

# 2 internet gateway
resource "aws_internet_gateway" "project-igw" {
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = "dev-env"
  }
}

# 3 route table
resource "aws_route_table" "project-rt" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project-igw.id
  }

  tags = {
    Name = "dev-env"
  }
}

# 4 subnet
resource "aws_subnet" "project-subnet" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-env"
  }
}

# 5 associate subnet with route table
resource "aws_route_table_association" "project-rta" {
  subnet_id      = aws_subnet.project-subnet.id
  route_table_id = aws_route_table.project-rt.id
}

# 6 security group
resource "aws_security_group" "project-sg" {
  name        = "project-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.project-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change this to your IP range for security
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "dev-env"
  }
}

# 7 network interface
resource "aws_network_interface" "project-nic" {
  subnet_id       = aws_subnet.project-subnet.id
  private_ips     = ["10.0.1.25"] # can assign multiple IPs if needed
  security_groups = [aws_security_group.project-sg.id]

  tags = {
    Name = "dev-env"
  }
}

# 8 Elastic IP
resource "aws_eip" "webserver_eip" {
  domain = "vpc"

  tags = {
    Name = "dev-env"
  }
}

# 9 EC2 instance
resource "aws_instance" "project_webserver" {
  ami                    = "ami-0bbdd8c17ed981ef9" # Amazon Linux 2 / Ubuntu AMI, update as needed
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.project-subnet.id
  vpc_security_group_ids = [aws_security_group.project-sg.id]

  key_name = var.key_pair_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              echo "Welcome to Terraform AWS Project" > /var/www/html/index.html
              EOF

  tags = {
    Name = "dev-env"
  }
}

variable "key_pair_name" {
  description = "The AWS key pair name for SSH access"
}

# 10 Associate Elastic IP with EC2
resource "aws_eip_association" "webserver_eip_assoc" {
  instance_id   = aws_instance.project_webserver.id
  allocation_id = aws_eip.webserver_eip.id
}

# 11 Budget Alert
resource "aws_budgets_budget" "like-and-subscribe" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "500.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2025-09-13_00:01"
}


