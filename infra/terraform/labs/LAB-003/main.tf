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
  function_name   = "config-demo-lab003"
  api_name        = "config-demo-api-lab003"
  lambda_zip_path = "${path.module}/../../../../artifacts/LAB-003/function.zip"
  handler         = "ConfigLabFunction::ConfigLabFunction.Function::FunctionHandler"
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "lab-003/app-config-${random_id.secret_suffix.hex}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    demoApiKey = "lab003-change-me-in-real-use"
  })
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
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "read_app_secret" {
  name = "${local.function_name}-read-secret"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.app.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "config_demo" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "config_demo" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_exec.arn

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  handler = local.handler
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 256

  environment {
    variables = {
      APP_ENV               = var.app_env
      SECRET_ARN            = aws_secretsmanager_secret.app.arn
      PUBLIC_FEATURE_TOGGLE = var.public_feature_toggle
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.read_app_secret,
    aws_cloudwatch_log_group.config_demo,
    aws_secretsmanager_secret_version.app
  ]
}

resource "aws_apigatewayv2_api" "config_demo" {
  name          = local.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "config_lambda" {
  api_id = aws_apigatewayv2_api.config_demo.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.config_demo.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "config" {
  api_id    = aws_apigatewayv2_api.config_demo.id
  route_key = "GET /config"
  target    = "integrations/${aws_apigatewayv2_integration.config_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.config_demo.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowHttpApiInvokeLab003"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config_demo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.config_demo.execution_arn}/*/*"
}
