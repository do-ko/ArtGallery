variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket for artwork storage"
}

variable "alb_dns" {
  type        = string
  description = "DNS of my app"
}