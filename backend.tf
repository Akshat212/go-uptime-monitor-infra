terraform {
  backend "s3" {
    bucket = "herbs-terraform-state-bucket"
    key = "cloud/terraform.tfstate"
    region = "ap-south-1"
  }
}