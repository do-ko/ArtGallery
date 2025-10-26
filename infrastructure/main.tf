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
