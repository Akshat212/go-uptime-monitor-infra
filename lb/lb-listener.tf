resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_alb.herbs-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}