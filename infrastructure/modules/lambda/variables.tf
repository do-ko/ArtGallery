variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type        = string
  description = "Lambda entrypoint handler (e.g. index.handler)"
}

variable "runtime" {
  type        = string
  description = "Runtime for the Lambda function (e.g. nodejs18.x)"
}

variable "existing_role_arn" {
  type        = string
  description = "ARN of an existing IAM role for Lambda execution"
}

variable "filename" {
  type        = string
  description = "Path to the Lambda deployment package zip file"
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Environment variables for Lambda"
}