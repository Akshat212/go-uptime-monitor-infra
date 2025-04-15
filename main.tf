# VPC Creation 
resource "aws_vpc" "herbs_main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "herbs-cloud-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "herbs_public_subnet" {
  vpc_id = aws_vpc.herbs_main_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name = "herbs-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "herbs_gw" {
  vpc_id = aws_vpc.herbs_main_vpc.id

  tags = {
    Name = "herbs-gw"
  }
}

# Route Tables
resource "aws_route_table" "herbs_rt" {
  vpc_id = aws_vpc.herbs_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.herbs_gw.id
  }

  tags = {
    Name = "herbs-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "herbs_rt_assoc" {
  subnet_id = aws_subnet.herbs_public_subnet.id
  route_table_id = aws_route_table.herbs_rt.id
}

# Security Group
resource "aws_security_group" "herbs_sg" {
  vpc_id = aws_vpc.herbs_main_vpc.id

  tags = {
    Name = "herbs-sg"
  }
}

# Security Group Igress Allow SSH
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.herbs_sg.id
  ip_protocol = "tcp"
  cidr_ipv4 = var.my_ip
  from_port = "22"
  to_port = "22"
}

# Security Group Igress Allow HTTP
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.herbs_sg.id
  ip_protocol = "tcp"
  cidr_ipv4 = aws_vpc.herbs_main_vpc.cidr_block
  from_port = "80"
  to_port = "80"
}

# Security Group Egress
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.herbs_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# EC2 instance
resource "aws_instance" "herbs_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.herbs_public_subnet.id
  vpc_security_group_ids = [ aws_security_group.herbs_sg.id ]
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt install postgresql postgresql-contrib -y
              sudo -u postgres psql -c "CREATE USER dev WITH PASSWORD 'password';"
              sudo -u postgres psql -c "CREATE DATABASE devdb OWNER dev;"
              echo "listen_addresses='*'" >> /etc/postgresql/14/main/postgresql.conf
              echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/14/main/pg_hba.conf
              systemctl restart postgresql
              EOF

  tags = {
    Name = "herbs-instance"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "herbs-s3-bucket" {
  bucket = "cloud-app-storage-${random_id.bucket_id.hex}"

  tags = {
    Name = "herbs-s3-bucket"
    Environment = "Dev"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8 
}

resource "aws_key_pair" "deployer" {
  key_name = "herbs-ec2-key"
  public_key = var.public_key
}