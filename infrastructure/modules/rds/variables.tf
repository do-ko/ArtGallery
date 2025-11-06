variable "db_name" { type = string }
variable "username" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ingress_security_group_ids" {
  description = "SG, które mogą łączyć się do RDS (np. SG backendu ECS)"
  type = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "engine_version" {
  type    = string
  default = "16"
}
variable "deletion_protection" {
  type    = bool
  default = false
}
variable "multi_az" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {}
}
