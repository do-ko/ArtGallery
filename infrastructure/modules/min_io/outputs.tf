output "access_key" {
  value = jsondecode(aws_secretsmanager_secret_version.minio_secret.secret_string)["access_key"]
}

output "secret_key" {
  value = jsondecode(aws_secretsmanager_secret_version.minio_secret.secret_string)["secret_key"]
}