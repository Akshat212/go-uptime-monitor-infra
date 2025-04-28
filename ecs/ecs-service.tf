resource "aws_ecs_service" "main" {
  name = "go-monitor-service"
  cluster = aws_ecs_cluster.go_monitoring_cluster.id
  task_definition = aws_ecs_task_definition.go_monitoring_task.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = var.subnet_ids
    security_groups = [ var.sg_id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name = "go-monitoring-cluster"
    container_port = 8080
  }

  depends_on = [ var.app_listener ]
}