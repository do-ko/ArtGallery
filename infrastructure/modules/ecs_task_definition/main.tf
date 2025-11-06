terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family             = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode       = "awsvpc"
  cpu                = var.cpu
  memory             = var.memory
  execution_role_arn = var.execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    merge(
      {
        name      = var.container_name
        image     = var.container_image_ref
        essential = true

        portMappings = [
          {
            containerPort = var.container_port
            protocol      = "tcp"
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.log_group_name
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = var.container_name
          }
        }
      },

        length(var.environment) > 0 ? {
        environment = var.environment
      } : {},

        length(var.secrets) > 0 ? {
        secrets = [
          for s in var.secrets :
          { name = s.name, valueFrom = s.value_from }
        ]
      } : {}
    )
  ])
}
