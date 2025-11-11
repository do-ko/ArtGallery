terraform {
  required_providers {
    aws    = { source = "hashicorp/aws",      version = "~> 5.0" }
    docker = { source = "kreuzwerker/docker", version = "~> 3.0" }
  }
}

locals {
  image_version = formatdate("YYYYMMDD-HHmmss", timestamp())
}

# LOKALNE BUDOWANIE OBRAZU
resource "docker_image" "image" {
  name = "${var.repo_url}:${local.image_version}"
  build {
    context    = var.path
    dockerfile = "Dockerfile"
    platform   = var.platform
  }
}

resource "docker_tag" "latest" {
  source_image = docker_image.image.name
  target_image = "${var.repo_url}:latest"
}

# PUSH DO ECR
resource "docker_registry_image" "versioned" {
  name = docker_image.image.name
}

resource "docker_registry_image" "latest" {
  name       = docker_tag.latest.target_image
  depends_on = [docker_tag.latest]
}

# DIGEST Z ECR (po pushu)
data "aws_ecr_image" "digest" {
  repository_name = var.repo_name
  image_tag       = local.image_version
  depends_on      = [docker_registry_image.versioned]
}
