output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "domain" {
  description = "Base Hosted UI domain URL"
  value = format(
    "https://%s.auth.%s.%s",
    aws_cognito_user_pool_domain.domain.domain,
    data.aws_region.current.id,
    data.aws_partition.current.dns_suffix
  )
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