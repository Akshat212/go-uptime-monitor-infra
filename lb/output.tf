output "app_listener" {
  value = aws_lb_listener.app_listener
}

output "tg_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}