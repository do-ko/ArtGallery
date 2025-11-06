terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ecr_authorization_token" "ecr" {
  registry_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

provider "docker" {
  registry_auth {
    address  = replace(data.aws_ecr_authorization_token.ecr.proxy_endpoint, "https://", "")
    username = data.aws_ecr_authorization_token.ecr.user_name
    password = data.aws_ecr_authorization_token.ecr.password
  }
}