provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block  = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-gateway"
  }
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "main-route-table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a security group
resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_all"
  }
}

# Create an IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

# Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Create EC2 key pair (ensure you have an existing key pair or create one manually)
resource "aws_key_pair" "key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")  # Update with the path to your public key file
}

# Create EC2 instances
resource "aws_instance" "k8s_master" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID for Ubuntu or other OS
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.main.id
  security_group = aws_security_group.allow_all.id
  key_name       = aws_key_pair.key_pair.key_name

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_node_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID for Ubuntu or other OS
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.main.id
  security_group = aws_security_group.allow_all.id
  key_name       = aws_key_pair.key_pair.key_name

  tags = {
    Name = "k8s-node-1"
  }
}

resource "aws_instance" "k8s_node_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID for Ubuntu or other OS
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.main.id
  security_group = aws_security_group.allow_all.id
  key_name       = aws_key_pair.key_pair.key_name

  tags = {
    Name = "k8s-node-2"
  }
}
