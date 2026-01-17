variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "alb_sg_id" {
  description = "ALB SG ID"
  type        = string
}

variable "keycloak_alb_listener_http_arn" {
  description = "ALB LISTENER HTTP ARN"
  type        = string
}

variable "alb_dns" {
  description = "ALB DNS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista id subnetów prywatnych"
  type = list(string)
}

variable "role_name" {
  description = "nazwa roli"
  type = string
}

variable "smtp_user" {
  type      = string
  sensitive = true
}

variable "smtp_app_password" {
  type      = string
  sensitive = true
}

variable aws_ami_id {
  description = "AWS AMI ID"
  type        = string
}

variable ec2_profile_name {
  description = "EC2 PROFILE NAME"
  type        = string
}