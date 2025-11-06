variable "repo_url" { type = string }
variable "repo_name" { type = string }

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_source" {
  type    = string
  default = "../art-frontend"
}

variable "backend_source" {
  type    = string
  default = "../art-backend"
}

variable "platform" {
  type    = string
  default = "linux/amd64"
}