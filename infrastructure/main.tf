data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

module "vpc" {
  source = "./modules/vpc"

  name = "art-vpc"
  azs = ["us-east-1a", "us-east-1b"]

  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

  create_nat_gateway = true
  single_nat_gateway = true

  tags = { Project = "art-gallery", Env = "dev" }
}

# LOAD BALANCER
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

resource "aws_security_group" "frontend" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [module.alb.alb_sg_id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [module.alb.alb_sg_id, module.prometheus.prometheus_sg_id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# =====================================
# EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = data.aws_iam_role.lab_role.name
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# KEYCLOAK
module "keycloak" {
  source                         = "./modules/keycloak"
  keycloak_alb_sg_id             = module.alb.alb_sg_id
  keycloak_vpc_id                = module.vpc.vpc_id
  private_subnet_ids             = module.vpc.private_subnet_ids
  role_name                      = data.aws_iam_role.lab_role.name
  keycloak_alb_listener_http_arn = module.alb.listener_http_arn
  alb_dns                        = module.alb.alb_dns_name
  smtp_user                      = var.smtp_user
  smtp_app_password              = var.smtp_app_password
  aws_ami_id = data.aws_ami.amazon_linux_2023.id
  ec2_profile_name = aws_iam_instance_profile.ec2_profile.name
}

# MINIO
module "min_io" {
  source      = "./modules/min_io"
  alb_dns     = module.alb.alb_dns_name
  alb_security_group_id = module.alb.alb_sg_id
  backend_security_group_id = aws_security_group.backend.id
  minio_alb_listener_http_arn = module.alb.listener_http_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  role_name = data.aws_iam_role.lab_role.name
  vpc_id = module.vpc.vpc_id
  aws_ami_id = data.aws_ami.amazon_linux_2023.id
  ec2_profile_name = aws_iam_instance_profile.ec2_profile.name
}

# POSTGRES
module "postgres" {
  source = "./modules/postgres"
  db_name = "artgallerydb"
  ingress_security_group_ids = [aws_security_group.backend.id]
  private_subnet_ids = module.vpc.private_subnet_ids
  role_name = data.aws_iam_role.lab_role.name
  username = "artgallerydbuser"
  vpc_id = module.vpc.vpc_id
  aws_ami_id = data.aws_ami.amazon_linux_2023.id
  ec2_profile_name = aws_iam_instance_profile.ec2_profile.name
}

# PROMETHEUS
module "prometheus" {
  source = "./modules/prometheus"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  aws_ami_id = data.aws_ami.amazon_linux_2023.id
  ec2_profile_name = aws_iam_instance_profile.ec2_profile.name
  alb_dns = module.alb.alb_dns_name
  alb_listener_http_arn = module.alb.listener_http_arn
  alb_sg_id = module.alb.alb_sg_id
}

# GRAFANA
module "grafana" {
  source = "./modules/grafana"
  vpc_id = module.vpc.vpc_id
  aws_ami_id = data.aws_ami.amazon_linux_2023.id
  ec2_profile_name = aws_iam_instance_profile.ec2_profile.name
  alb_sg_id = module.alb.alb_sg_id
  alb_listener_http_arn = module.alb.listener_http_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_dns = module.alb.alb_dns_name
}

# =====================================


# ECR
module "ecr" {
  source = "./modules/ecr"
  region = var.region
}

module "frontend_image_build" {
  source    = "./modules/image_build"
  repo_url  = module.ecr.frontend_repo_url
  repo_name = module.ecr.frontend_repo_name
  path      = "../art-frontend"
}

module "backend_image_build" {
  source    = "./modules/image_build"
  repo_url  = module.ecr.backend_repo_url
  repo_name = module.ecr.backend_repo_name
  path      = "../art-backend"
}

# CLOUDWATCH
module "frontend_logs" {
  source = "./modules/logs"
  name   = "/ecs/art-frontend"
  tags = { Project = "art-gallery", Component = "frontend" }
}

module "backend_logs" {
  source = "./modules/logs"
  name   = "/ecs/art-backend"
  tags = { Project = "art-gallery", Component = "backend" }
}

# ECS
module "ecs_cluster" {
  source = "./modules/ecs_cluster"
  name   = "art-ecs"
}

module "frontend_taskdef" {
  source              = "./modules/ecs_task_definition"
  family              = "art-frontend"
  execution_role_arn  = data.aws_iam_role.lab_role.arn
  task_role_arn       = data.aws_iam_role.lab_role.arn
  container_image_ref = module.frontend_image_build.image_ref
  aws_region          = var.region
  log_group_name      = module.frontend_logs.log_group_name
  container_name      = "frontend-container"
  container_port      = 80

  environment = [
    { name = "AWS_REGION", value = var.region },
    { name = "API_BASE", value = "/api" },
    { name = "KEYCLOAK_CLIENT_ID", value = "art-gallery-frontend" },
    { name = "KEYCLOAK_REALM", value = "art-gallery" }
  ]

  depends_on = [module.frontend_image_build]
}

module "backend_taskdef" {
  source              = "./modules/ecs_task_definition"
  family              = "art-backend"
  execution_role_arn  = data.aws_iam_role.lab_role.arn
  task_role_arn       = data.aws_iam_role.lab_role.arn
  container_image_ref = module.backend_image_build.image_ref
  aws_region          = var.region
  log_group_name      = module.backend_logs.log_group_name
  container_name      = "backend-container"
  container_port      = 8080

  environment = [
    {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:postgresql://${module.postgres.db_endpoint}:5432/artgallerydb"
    },
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = "prod"
    },
    {
      name  = "KEYCLOAK_ISSUER_URI"
      value = "http://${module.alb.alb_dns_name}/realms/art-gallery"
    },
    {
      name  = "MINIO_BUCKET"
      value = "bucket"
    },
    {
      name  = "MINIO_ENDPOINT"
      value = "http://${module.alb.alb_dns_name}"
    },
    {
      name  = "MINIO_ACCESS_KEY"
      value = module.min_io.access_key
    },
    {
      name  = "MINIO_SECRET_KEY"
      value = module.min_io.secret_key
    }
  ]

  secrets = [
    {
      name       = "SPRING_DATASOURCE_USERNAME"
      value_from = "${module.postgres.db_secret_arn}:username::"
    },
    {
      name       = "SPRING_DATASOURCE_PASSWORD"
      value_from = "${module.postgres.db_secret_arn}:password::"
    }
  ]

  depends_on = [module.backend_image_build, module.postgres]
}

# ECS SERVICE
module "ecs_service_frontend" {
  source           = "./modules/ecs_service"
  name             = "frontend-service"
  cluster_id       = module.ecs_cluster.id
  task_definition  = module.frontend_taskdef.task_definition_arn
  subnets          = module.vpc.private_subnet_ids
  security_groups = [aws_security_group.frontend.id]
  assign_public_ip = false
  desired_count    = 2


  load_balancers = [
    {
      target_group_arn = module.alb.fe_tg_arn
      container_name   = "frontend-container"
      container_port   = 80
    }
  ]

  depends_on = [module.alb.listener_http_arn]
}

module "ecs_service_backend" {
  source           = "./modules/ecs_service"
  name             = "backend-service"
  cluster_id       = module.ecs_cluster.id
  task_definition  = module.backend_taskdef.task_definition_arn
  subnets          = module.vpc.private_subnet_ids
  security_groups = [aws_security_group.backend.id]
  assign_public_ip = false
  desired_count    = 2

  load_balancers = [
    {
      target_group_arn = module.alb.be_tg_arn
      container_name   = "backend-container"
      container_port   = 8080
    }
  ]

  depends_on = [module.alb.listener_http_arn]
}

