resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.existing_role_arn
  filename      = var.filename

  environment {
    variables = var.environment
  }
}