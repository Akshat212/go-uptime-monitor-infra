resource "aws_lb_target_group" "ecs_tg" {
  name = "go-monitor-tg"
  protocol = "HTTP"
  port = 8080
  vpc_id = var.vpc_id

  target_type = "ip"
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}