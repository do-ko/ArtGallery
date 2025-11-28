variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_secret" {
  description = "Secret value for lambda request"
  type        = string
  default = "secretendpoint"
}