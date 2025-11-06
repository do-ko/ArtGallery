variable "repo_url" { type = string }
variable "repo_name" { type = string }

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "path" {
  type    = string
}

variable "platform" {
  type    = string
  default = "linux/amd64"
}