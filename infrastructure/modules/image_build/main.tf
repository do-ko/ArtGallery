terraform {
  required_providers {
    aws    = { source = "hashicorp/aws",      version = "~> 5.0" }
    docker = { source = "kreuzwerker/docker", version = "~> 3.0" }
  }
}

# LOKALNE BUDOWANIE OBRAZU
resource "docker_image" "image" {
  name = "${var.repo_url}:${var.image_tag}"
  build {
    context    = var.path
    dockerfile = "Dockerfile"
    platform   = var.platform
  }
}

# PUSH DO ECR
resource "docker_registry_image" "image" {
  name = docker_image.image.name
}

# DIGEST Z ECR (po pushu)
data "aws_ecr_image" "this" {
  repository_name = var.repo_name
  image_tag       = var.image_tag
  depends_on      = [docker_registry_image.image]
}
