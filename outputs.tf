output "public_ip" {
  value = aws_instance.herbs_instance.public_ip
}

output "s3_bucket" {
  value = aws_s3_bucket.herbs-s3-bucket.bucket
}

output "aws_ecr_url" {
  value = aws_ecr_repository.go-uptime-monitor-app.repository_url
}