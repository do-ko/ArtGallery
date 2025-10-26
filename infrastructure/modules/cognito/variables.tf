variable "name" {
  description = "Nazwa user pool"
  type        = string
}

variable "domain_prefix" {
  description = "Prefiks domeny Cognito (musi być globalnie unikalny w regionie)"
  type        = string
}

variable "password_policy" {
  description = "Parametry polityki haseł"
  type = object({
    minimum_length    : number
    require_uppercase : bool
    require_lowercase : bool
    require_numbers   : bool
    require_symbols   : bool
  })
  default = {
    minimum_length    = 6
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }
}

variable "auto_verified_attributes" {
  description = "Atrybuty automatycznie weryfikowane"
  type        = list(string)
  default     = ["email"]
}

variable "enable_email_link_confirm" {
  description = "Czy użyć linku weryfikacyjnego w mailu"
  type        = bool
  default     = true
}

variable "app_client_name" {
  description = "Nazwa klienta (SPA)"
  type        = string
}

variable "app_client_oauth" {
  description = "Konfiguracja OAuth dla Hosted UI"
  type = object({
    allowed_oauth_flows_user_pool_client : bool
    allowed_oauth_flows                  : list(string)
    allowed_oauth_scopes                 : list(string)
    callback_urls                        : list(string)
    logout_urls                          : list(string)
    prevent_user_existence_errors        : string
    access_token_validity_hours          : number
    id_token_validity_hours              : number
    refresh_token_validity_hours         : number
    generate_secret                      : bool
  })
  default = {
    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_flows                  = ["code"]
    allowed_oauth_scopes                 = ["openid","email","profile"]
    callback_urls                        = []
    logout_urls                          = []
    prevent_user_existence_errors        = "LEGACY"
    access_token_validity_hours          = 1
    id_token_validity_hours              = 1
    refresh_token_validity_hours         = 3
    generate_secret                      = false
  }
}
