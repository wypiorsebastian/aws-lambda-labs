terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  function_name     = "jwt-demo-lab004"
  api_name          = "jwt-demo-api-lab004"
  lambda_zip_path   = "${path.module}/../../../../artifacts/LAB-004/function.zip"
  handler           = "JwtLabFunction::JwtLabFunction.Function::FunctionHandler"
  cognito_issuer    = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.lab.id}"
  default_tags = merge(
    var.lab_tags,
    { Lab = "LAB-004" }
  )
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_cognito_user_pool" "lab" {
  name = "lab004-user-pool-${random_id.suffix.hex}"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = "OFF"

  tags = local.default_tags
}

resource "aws_cognito_user_pool_client" "http_api" {
  name         = "lab004-http-api-public-client"
  user_pool_id = aws_cognito_user_pool.lab.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "jwt_demo" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14

  tags = local.default_tags
}

resource "aws_lambda_function" "jwt_demo" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_exec.arn

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  handler = local.handler
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 256

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.jwt_demo
  ]
}

resource "aws_apigatewayv2_api" "jwt_demo" {
  name          = local.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["authorization", "content-type"]
    allow_methods = ["GET", "OPTIONS"]
    allow_origins = ["*"]
    max_age         = 300
  }

  tags = local.default_tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.jwt_demo.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.jwt_demo.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id           = aws_apigatewayv2_api.jwt_demo.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "lab004-cognito-jwt"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.http_api.id]
    issuer   = local.cognito_issuer
  }
}

resource "aws_apigatewayv2_route" "public" {
  api_id    = aws_apigatewayv2_api.jwt_demo.id
  route_key = "GET /public"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "claims" {
  api_id             = aws_apigatewayv2_api.jwt_demo.id
  route_key          = "GET /claims"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.jwt_demo.id
  name        = "$default"
  auto_deploy = true

  tags = local.default_tags
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowHttpApiInvokeLab004"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jwt_demo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.jwt_demo.execution_arn}/*/*"
}
