variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }

variable "lb_name" {
  type    = string
  default = "art-alb"
}
variable "fe_tg_name" {
  type    = string
  default = "tg-frontend"
}
variable "be_tg_name" {
  type    = string
  default = "tg-backend"
}

variable "fe_port" {
  type    = number
  default = 80
}
variable "be_port" {
  type    = number
  default = 8080
}

variable "fe_health_path" {
  type    = string
  default = "/"
}
variable "be_health_path" {
  type    = string
  default = "/api"
}

variable "api_path_pattern" {
  type    = string
  default = "/api/*"
}