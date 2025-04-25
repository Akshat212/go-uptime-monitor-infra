resource "aws_alb" "herbs-alb" {
  name = "herbs-alb"
  internal = false
  load_balancer_type = "application"
  subnets = [ aws_subnet.herbs_public_subnet.id, aws_subnet.herbs_public_subnet_2 ]
  security_groups = [ aws_security_group.herbs_sg.id ]

  enable_deletion_protection = false
}