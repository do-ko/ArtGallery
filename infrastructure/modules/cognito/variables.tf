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
    minimum_length : number
    require_uppercase : bool
    require_lowercase : bool
    require_numbers : bool
    require_symbols : bool
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
  type = list(string)
  default = ["email"]
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

variable "app_client_times" {
  type = object({
    access_token_validity_hours : number
    id_token_validity_hours : number
    refresh_token_validity_hours : number
  })
  default = {
    access_token_validity_hours          = 1
    id_token_validity_hours              = 1
    refresh_token_validity_hours         = 3
  }
}
