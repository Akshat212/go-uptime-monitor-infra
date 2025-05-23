# VPC Creation 
resource "aws_vpc" "herbs_main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "herbs-cloud-vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "herbs_public_subnet" {
  vpc_id = aws_vpc.herbs_main_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name = "herbs-public-subnet"
  }
}

# Public Subnet 2
resource "aws_subnet" "herbs_public_subnet_2" {
  vpc_id = aws_vpc.herbs_main_vpc.id
  cidr_block = var.subnet_cidr_2
  map_public_ip_on_launch = true
  availability_zone = "${var.region}b"

  tags = {
    Name = "herbs-public-subnet-2"
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

# Route Table Association Subnet 1
resource "aws_route_table_association" "herbs_rt_assoc_subnet_1" {
  subnet_id = aws_subnet.herbs_public_subnet.id
  route_table_id = aws_route_table.herbs_rt.id
}

# Route Table Association Subnet 2
resource "aws_route_table_association" "herbs_rt_assoc_subnet_2" {
  subnet_id = aws_subnet.herbs_public_subnet_2.id
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
  from_port = 22
  to_port = 22
}

# Security Group Igress Allow HTTP
# resource "aws_vpc_security_group_ingress_rule" "allow_http" {
#   security_group_id = aws_security_group.herbs_sg.id
#   ip_protocol = "tcp"
#   cidr_ipv4 = aws_vpc.herbs_main_vpc.cidr_block
#   from_port = 80
#   to_port = 80
# }

# Security Group Ingress 
# resource "aws_vpc_security_group_ingress_rule" "allow_alb_to_ecs" {
#   security_group_id = aws_security_group.herbs_sg.id
#   ip_protocol = "tcp"
#   from_port = 8080
#   to_port = 8080
#   cidr_ipv4 = "0.0.0.0/0"
# }

# Security Group Allow Ingress HTTPS
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.herbs_sg.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
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

# ECR registry
resource "aws_ecr_repository" "go-uptime-monitor-app" {
  name = "go-uptime-monitor-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR registry rule
resource "aws_ecr_lifecycle_policy" "herbs-ecr-policy" {
  repository = aws_ecr_repository.go-uptime-monitor-app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority : 1
        description : "Keep last 10 images"
        selection : {
          tagStatus : "any"
          countType : "imageCountMoreThan"
          countNumber : 10
        }
        action = {
          type : "expire"
        }
      }
    ]
  })
}

# Log group
resource "aws_cloudwatch_log_group" "ecs-app" {
  name = "/ecs/go-monitor-app"
  retention_in_days = 7
}

resource "random_id" "bucket_id" {
  byte_length = 8 
}

resource "aws_key_pair" "deployer" {
  key_name = "herbs-ec2-key"
  public_key = var.public_key
}

module "ecs" {
  source = "./ecs"
  sg_id = aws_security_group.herbs_sg.id
  subnet_ids = [ aws_subnet.herbs_public_subnet.id, aws_subnet.herbs_public_subnet_2.id ]
  tg_arn = module.lb.tg_arn
  app_listener = module.lb.app_listener
  ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

module "lb" {
  source = "./lb"
  sg_id = aws_security_group.herbs_sg.id
  subnet_ids = [ aws_subnet.herbs_public_subnet.id, aws_subnet.herbs_public_subnet_2.id ]
  vpc_id = aws_vpc.herbs_main_vpc.id
  acm_cert_arn = var.aws_acm_arn
}