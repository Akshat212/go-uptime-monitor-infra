# Go Uptime Monitor – Infrastructure

This repo contains the Terraform configuration for deploying the infrastructure of the Go Uptime Monitor project on AWS.

## 🧱 Provisions

- AWS EC2 instance (Amazon Linux 2)
- Security Group with SSH and HTTP access
- Key Pair configuration
- Public IP output

## 🚀 Usage

```bash
terraform init
terraform plan
terraform apply