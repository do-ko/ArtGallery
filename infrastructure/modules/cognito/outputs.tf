output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

data "aws_region" "current" {}

data "aws_partition" "current" {}

output "issuer_url" {
  description = "OIDC issuer dla Cognito"
  value       = format(
    "https://cognito-idp.%s.%s/%s",
    data.aws_region.current.id,
    data.aws_partition.current.dns_suffix,
    aws_cognito_user_pool.pool.id
  )
}