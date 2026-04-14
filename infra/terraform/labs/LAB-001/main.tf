# Terraform skeleton for LAB-001
# Cel: Lambda .NET 8 (zip deployment) + HTTP API Gateway → GET /health

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# IAM — execution role dla Lambda
# ─────────────────────────────────────────────

# TODO: Utwórz zasób aws_iam_role dla Lambda
# - Trust policy: principal "lambda.amazonaws.com", action "sts:AssumeRole"
# - Nazwa roli: np. "${var.function_name}-role"

# resource "aws_iam_role" "lambda_exec" {
#   name = "${var.function_name}-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# TODO: Dołącz managed policy AWSLambdaBasicExecutionRole (uprawnienia do CloudWatch Logs)
# ARN: "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

# resource "aws_iam_role_policy_attachment" "basic_execution" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# ─────────────────────────────────────────────
# Lambda function (zip deployment)
# ─────────────────────────────────────────────

# TODO: Utwórz zasób aws_lambda_function
# - filename: ścieżka do function.zip (względna lub bezwzględna)
# - source_code_hash: filebase64sha256(...) — WAŻNE, inaczej Terraform nie wykryje zmian w paczce
# - runtime: "dotnet8"
# - handler: "HealthFunction::HealthFunction.Function::FunctionHandler"
# - role: ARN roli powyżej
# - timeout: 10 (sekundy)
# - memory_size: 256 (MB)

# resource "aws_lambda_function" "health" {
#   function_name    = var.function_name
#   filename         = var.zip_path
#   source_code_hash = filebase64sha256(var.zip_path)
#   runtime          = "dotnet8"
#   handler          = "HealthFunction::HealthFunction.Function::FunctionHandler"
#   role             = aws_iam_role.lambda_exec.arn
#   timeout          = 10
#   memory_size      = 256
# }

# ─────────────────────────────────────────────
# CloudWatch Log Group (opcjonalnie explicit)
# ─────────────────────────────────────────────

# TODO (opcjonalnie): Utwórz aws_cloudwatch_log_group z retention i force_destroy
# Jeśli tego nie zrobisz, Lambda sama go stworzy, ale Terraform nie będzie go zarządzał
# i nie usunie go podczas terraform destroy.

# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   name              = "/aws/lambda/${var.function_name}"
#   retention_in_days = 7
# }

# ─────────────────────────────────────────────
# HTTP API Gateway
# ─────────────────────────────────────────────

# TODO: Utwórz aws_apigatewayv2_api
# - protocol_type: "HTTP"
# - name: np. "${var.function_name}-api"

# resource "aws_apigatewayv2_api" "http_api" {
#   name          = "${var.function_name}-api"
#   protocol_type = "HTTP"
# }

# TODO: Utwórz aws_apigatewayv2_integration (Lambda proxy)
# - api_id: referencja do api powyżej
# - integration_type: "AWS_PROXY"
# - integration_uri: ARN funkcji Lambda (invoke_arn)
# - payload_format_version: "1.0"

# resource "aws_apigatewayv2_integration" "lambda" {
#   api_id                 = aws_apigatewayv2_api.http_api.id
#   integration_type       = "AWS_PROXY"
#   integration_uri        = aws_lambda_function.health.invoke_arn
#   payload_format_version = "1.0"
# }

# TODO: Utwórz aws_apigatewayv2_route
# - route_key: "GET /health"
# - target: "integrations/${integration_id}"

# resource "aws_apigatewayv2_route" "health_route" {
#   api_id    = aws_apigatewayv2_api.http_api.id
#   route_key = "GET /health"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
# }

# TODO: Utwórz aws_apigatewayv2_stage z auto_deploy = true
# - Nazwa stage: "$default" lub np. "dev"
# - auto_deploy: true (stage deployuje się automatycznie po zmianie trasy)

# resource "aws_apigatewayv2_stage" "default" {
#   api_id      = aws_apigatewayv2_api.http_api.id
#   name        = "$default"
#   auto_deploy = true
# }

# ─────────────────────────────────────────────
# Lambda permission — pozwól API Gateway wywołać funkcję
# ─────────────────────────────────────────────

# TODO: Utwórz aws_lambda_permission
# - action: "lambda:InvokeFunction"
# - function_name: nazwa funkcji
# - principal: "apigateway.amazonaws.com"
# - source_arn: "${api_execution_arn}/*/*"

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.health.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
# }
