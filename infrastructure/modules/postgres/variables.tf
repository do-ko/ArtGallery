variable "role_name" {
  description = "nazwa roli"
  type        = string
}

variable "db_name" { type = string }
variable "username" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "backend_sg_id" {
  description = "BACKEND SG ID"
  type = string
}
variable aws_ami_id {
  description = "AWS AMI ID"
  type        = string
}

variable ec2_profile_name {
  description = "EC2 PROFILE NAME"
  type        = string
}