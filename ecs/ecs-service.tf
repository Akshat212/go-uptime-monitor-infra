resource "aws_ecs_service" "main" {
  name = "go-monitor-service"
  cluster = aws_ecs_cluster.go_monitoring_cluster.id
  task_definition = aws_ecs_task_definition.go_monitoring_task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = [ aws_subnet.herbs_public_subnet.id, aws_subnet.herbs_public_subnet_2.id ]
    security_groups = [ aws_security_group.herbs_sg.id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name = "go-uptime-monitor-container"
    container_port = 8080
  }

  depends_on = [ aws_lb_listener.app_listener ]
}