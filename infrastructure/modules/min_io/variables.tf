variable "vpc_id" { type = string }
variable "backend_security_group_id" {
  description = "Backend SG"
  type = string
}
variable "alb_security_group_id" {
  description = "ALB SG"
  type = string
}
variable "private_subnet_ids" { type = list(string) }
variable "role_name" {
  description = "nazwa roli"
  type = string
}
variable "minio_alb_listener_http_arn" {
  description = "ALB LISTENER HTTP ARN"
  type        = string
}
variable "alb_dns" {
  description = "ALB DNS"
  type        = string
}
variable aws_ami_id {
  description = "AWS AMI ID"
  type        = string
}

variable ec2_profile_name {
  description = "EC2 PROFILE NAME"
  type        = string
}