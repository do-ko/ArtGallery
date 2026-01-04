output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "db_endpoint" {
  value = aws_instance.postgres.private_dns
}