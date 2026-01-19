output "minio_secret_arn" {
  value = aws_secretsmanager_secret.minio_secret.arn
}