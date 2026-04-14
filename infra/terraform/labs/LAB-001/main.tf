terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  function_name   = "health-function-lab001"
  lambda_zip_path = "${path.module}/../../../../artifacts/LAB-001/function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "health-function-lab001-exec-role"

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

resource "aws_cloudwatch_log_group" "health" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "health" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_exec.arn

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  handler = "HealthFunction::HealthFunction.Function::FunctionHandler"
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 5
  memory_size   = 256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.health
  ]
}

resource "aws_apigatewayv2_api" "health" {
  name          = "health-api-lab001"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "health_lambda" {
  api_id = aws_apigatewayv2_api.health.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.health.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.health.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.health_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.health.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowHttpApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.health.execution_arn}/*/*"
}

output "api_base_url" {
  value = aws_apigatewayv2_api.health.api_endpoint
}

output "health_url" {
  value = "${aws_apigatewayv2_api.health.api_endpoint}/health"
}
