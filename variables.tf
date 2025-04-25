# AWS region
variable "region" {
  default = "ap-south-1"
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  default = "t2.micro"
}

# AMI ID
variable "ami_id" {
  description = "Amazon Linux 2023 AMI"
  default = "ami-002f6e91abff6eb96"
}

# VPC CIDR
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# Subnet CIDR
variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

# Key
variable "public_key" {
  description = "Publick Key for EC2 SSH access"
  type = string
}

# IP
variable "my_ip" {
  description = "My IP address with CIDR suffix"
  type = string
}