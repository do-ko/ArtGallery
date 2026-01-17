variable "vpc_id" { type = string }
variable aws_ami_id {
  description = "AWS AMI ID"
  type        = string
}
variable ec2_profile_name {
  description = "EC2 PROFILE NAME"
  type        = string
}
variable "private_subnet_ids" { type = list(string) }
variable "alb_dns" {
  description = "ALB DNS"
  type        = string
}
variable "alb_listener_http_arn" {
  description = "ALB LISTENER HTTP ARN"
  type        = string
}
variable "alb_sg_id" {
  description = "ALB SG ID"
  type        = string
}