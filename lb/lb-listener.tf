resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_alb.herbs-alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.acm_cert_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}