output "endpoint"     { value = aws_db_instance.postgres.address }
output "port"         { value = aws_db_instance.postgres.port }
output "dbname"       { value = aws_db_instance.postgres.db_name }
output "username"     { value = aws_db_instance.postgres.username }
output "password_arn" { value = aws_secretsmanager_secret.db_password.arn }
output "security_group_id" { value = aws_security_group.rds.id }