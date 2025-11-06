terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "art-frontend"
  image_tag_mutability = "MUTABLE"
  encryption_configuration { encryption_type = "AES256" }
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
  tags = { Project = "art-gallery", Component = "frontend" }
}

resource "aws_ecr_repository" "backend" {
  name = "art-backend"
  image_tag_mutability = "MUTABLE"
  encryption_configuration { encryption_type = "AES256" }
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
  tags = { Project = "art-gallery", Component = "backend" }
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name
  policy     = jsonencode({ rules = [{ rulePriority=1, description="Keep last 10 images",
    selection={ tagStatus="any", countType="imageCountMoreThan", countNumber=10 },
    action={ type="expire" } }]})
}

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name
  policy     = aws_ecr_lifecycle_policy.frontend.policy
}


# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#     docker = {
#       source  = "kreuzwerker/docker"
#       version = "~> 3.0"
#     }
#   }
# }
#
# resource "aws_ecr_repository" "frontend" {
#   name                 = "art-frontend"
#   image_tag_mutability = "MUTABLE"
#   encryption_configuration { encryption_type = "AES256" }
#   image_scanning_configuration { scan_on_push = true }
#   force_delete         = true
#   tags = { Project = "art-gallery", Component = "frontend" }
# }
#
# resource "aws_ecr_repository" "backend" {
#   name                 = "art-backend"
#   image_tag_mutability = "MUTABLE"
#   encryption_configuration { encryption_type = "AES256" }
#   image_scanning_configuration { scan_on_push = true }
#   force_delete         = true
#   tags = { Project = "art-gallery", Component = "backend" }
# }
#
#
# resource "aws_ecr_lifecycle_policy" "frontend" {
#   repository = aws_ecr_repository.frontend.name
#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1, description = "Keep last 10 images",
#         selection = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 10 },
#         action = { type = "expire" }
#       }
#     ]
#   })
# }
#
# resource "aws_ecr_lifecycle_policy" "backend" {
#   repository = aws_ecr_repository.backend.name
#   policy     = aws_ecr_lifecycle_policy.frontend.policy
# }
#
# # OBRAZY
# resource "docker_image" "frontend" {
#   name = "${aws_ecr_repository.frontend.repository_url}:${var.image_tag}"
#   build {
#     context    = var.frontend_source
#     dockerfile = "Dockerfile"
#     platform   = "linux/amd64"
#   }
# }
#
# # PUSHOWANIE OBRAZÓW
# resource "docker_registry_image" "frontend" {
#   name = docker_image.frontend.name
# }
#
# data "aws_ecr_image" "frontend" {
#   repository_name = aws_ecr_repository.frontend.name
#   image_tag       = var.image_tag
#   depends_on = [docker_registry_image.frontend]
# }
#
# # IAM
# data "aws_iam_role" "lab_role" {
#   name = "LabRole"
# }
#
# # CLOUDWATCH
# resource "aws_cloudwatch_log_group" "app" {
#   name              = "/ecs/art-frontend"
#   retention_in_days = 14
#   tags = { Project = "art-gallery", Component = "frontend" }
# }
#
#
# # TASK DEFINITION
# resource "aws_ecs_task_definition" "frontend" {
#   family             = "art-frontend"
#   requires_compatibilities = ["FARGATE"]
#   network_mode       = "awsvpc"
#   cpu                = "256"
#   memory             = "512"
#   execution_role_arn = data.aws_iam_role.lab_role.arn
#
#   runtime_platform {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "X86_64"
#   }
#
#   container_definitions = jsonencode([
#     {
#       name      = "frontend"
#       image     = "${aws_ecr_repository.frontend.repository_url}@${data.aws_ecr_image.frontend.image_digest}"
#       essential = true
#
#       portMappings = [
#         {
#           containerPort = 80
#           protocol      = "tcp"
#         }
#       ]
#
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.app.name
#           awslogs-region        = var.region
#           awslogs-stream-prefix = "frontend"
#         }
#       }
#     }
#   ])
#
#   depends_on = [docker_registry_image.frontend]
# }
