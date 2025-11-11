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

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity        = var.app_client_times.access_token_validity_hours
  id_token_validity            = var.app_client_times.id_token_validity_hours
  refresh_token_validity       = var.app_client_times.refresh_token_validity_hours

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "hours"
  }
}
