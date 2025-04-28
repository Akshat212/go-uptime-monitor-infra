resource "aws_alb" "herbs-alb" {
  name = "herbs-alb"
  internal = false
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [ var.sg_id ]

  enable_deletion_protection = false
}