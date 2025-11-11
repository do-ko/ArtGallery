// CREATING USER POOL FOR COGNITO
resource "aws_cognito_user_pool" "pool" {
  name = var.name

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  auto_verified_attributes = var.auto_verified_attributes

  dynamic "verification_message_template" {
    for_each = var.enable_email_link_confirm ? [1] : []
    content {
      default_email_option = "CONFIRM_WITH_LINK"
    }
  }

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
  }

  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_uppercase = var.password_policy.require_uppercase
    require_lowercase = var.password_policy.require_lowercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

// CREATING COGNITO USER POOL CLIENT
resource "aws_cognito_user_pool_client" "client" {
  name         = var.app_client_name
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret               = var.app_client_oauth.generate_secret
  prevent_user_existence_errors = var.app_client_oauth.prevent_user_existence_errors

  allowed_oauth_flows_user_pool_client = var.app_client_oauth.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = var.app_client_oauth.allowed_oauth_flows
  allowed_oauth_scopes                 = var.app_client_oauth.allowed_oauth_scopes
  callback_urls                        = var.app_client_oauth.callback_urls
  logout_urls                          = var.app_client_oauth.logout_urls

  access_token_validity  = var.app_client_oauth.access_token_validity_hours
  id_token_validity      = var.app_client_oauth.id_token_validity_hours
  refresh_token_validity = var.app_client_oauth.refresh_token_validity_hours
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "hours"
  }
}

// CREATE COGNITO DOMAIN
resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.pool.id
}