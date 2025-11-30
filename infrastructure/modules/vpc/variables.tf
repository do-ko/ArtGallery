variable "name" {
  description = "Nazwa VPC (tag Name)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR dla VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Lista AZ (np. [\"us-east-1a\",\"us-east-1b\"])"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRy dla publicznych podsieci (1:1 z azs)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRy dla prywatnych podsieci (1:1 z azs)"
  type        = list(string)
}

variable "tags" {
  description = "Dodatkowe tagi"
  type        = map(string)
  default     = {}
}