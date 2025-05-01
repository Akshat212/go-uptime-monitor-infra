resource "aws_ecs_task_definition" "go_monitoring_task" {
  family = "go-monitoring-task"
  requires_compatibilities = [ "FARGATE" ]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"

  execution_role_arn = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
        name = "go-monitoring-cluster"
        image = "351933853465.dkr.ecr.ap-south-1.amazonaws.com/go-uptime-monitor-app:latest"
        portMappings = [
            {
                containerPort = 8080
                hostPort = 8080
            }
        ],
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group = "/ecs/go-monitor-app",
            awslogs-create-group = "true",
            awslogs-region = "ap-south-1",
            awslogs-stream-prefix = "ecs"
          }
        }
    }
  ])
}