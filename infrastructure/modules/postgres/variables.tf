variable "role_name" {
  description = "nazwa roli"
  type = string
}

variable "db_name" { type = string }
variable "username" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ingress_security_group_ids" {
  description = "SG, które mogą łączyć się do RDS (np. SG backendu ECS)"
  type = list(string)
}