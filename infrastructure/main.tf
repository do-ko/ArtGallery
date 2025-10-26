module "cognito" {
  source        = "./modules/cognito"
  name          = "art_user_pool"
  domain_prefix = "do-ko-art-domain"

  app_client_name = "art-client"
  app_client_oauth = {
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_flows                  = ["code"]
    allowed_oauth_scopes                 = ["openid","email","profile"]
    callback_urls                        = ["https://frontend.example.com/callback"]
    logout_urls                          = ["https://frontend.example.com/"]
    prevent_user_existence_errors        = "LEGACY"
    access_token_validity_hours          = 1
    id_token_validity_hours              = 1
    refresh_token_validity_hours         = 3
    generate_secret                      = false
  }
}

module "vpc" {
  source = "./modules/vpc"

  name  = "art-vpc"
  azs = ["us-east-1a", "us-east-1b"]

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24",  "10.0.2.0/24"]

  create_nat_gateway  = true
  single_nat_gateway  = true

  tags = { Project = "art-gallery", Env = "dev" }
}


# module "rds" {
#   source                  = "./modules/rds"
#   db_name                 = "gallery"
#   username                = "appuser"
#   vpc_id                  = module.vpc.id
#   private_subnet_ids      = module.vpc.private_subnet_ids
#   ingress_security_group_ids = [module.backend.sg_id]
#   tags = { Project = "art-gallery", Env = "dev" }
# }