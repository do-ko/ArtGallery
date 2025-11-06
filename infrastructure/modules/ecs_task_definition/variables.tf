variable "family" { type = string }
variable "execution_role_arn" { type = string }
variable "container_image_ref" { type = string }
variable "aws_region" { type = string }
variable "log_group_name" { type = string }

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "environment" {
  type = list(object({ name = string, value = string }))
  default = []
}
variable "secrets" {
  type = list(object({ name = string, value_from = string }))
  default = []
}