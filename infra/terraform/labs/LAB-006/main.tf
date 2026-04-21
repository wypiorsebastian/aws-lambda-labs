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
  region = var.aws_region
}

locals {
  api_name           = "public-observability-api-lab006"
  function_name      = "public-observability-lab006"
  lambda_zip_path    = "${path.module}/../../../../${var.function_zip_path}"
  lambda_handler     = "ObservabilityLabFunction::ObservabilityLabFunction.Function::FunctionHandler"
  api_log_group_name = "/aws/apigateway/lab006-http-access"

  default_tags = merge(
    var.lab_tags,
    { Lab = "LAB-006" }
  )
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

resource "aws_iam_role_policy_attachment" "lambda_xray_write" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.lambda_log_retention_days
  tags              = local.default_tags
}

resource "aws_lambda_function" "backend" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_exec.arn

  filename         = local.lambda_zip_path
  source_code_hash = filebase64sha256(local.lambda_zip_path)

  # TODO(lab-006): dopasuj handler do namespace/klasy w projekcie LAB-006.
  handler = local.lambda_handler
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 15
  memory_size   = 256

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      POWERTOOLS_SERVICE_NAME = "lab006-public-api"
      POWERTOOLS_LOG_LEVEL    = "Information"
      # TODO(lab-006): ewentualnie dodaj POWERTOOLS_METRICS_NAMESPACE.
    }
  }

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_xray_write,
    aws_cloudwatch_log_group.lambda
  ]
}

resource "aws_apigatewayv2_api" "lab" {
  name          = local.api_name
  protocol_type = "HTTP"
  tags          = local.default_tags
}

resource "aws_apigatewayv2_integration" "backend" {
  api_id = aws_apigatewayv2_api.lab.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.lab.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}

resource "aws_apigatewayv2_route" "order" {
  api_id    = aws_apigatewayv2_api.lab.id
  route_key = "GET /orders/{orderId}"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}

resource "aws_apigatewayv2_route" "fail" {
  api_id    = aws_apigatewayv2_api.lab.id
  route_key = "GET /fail"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = local.api_log_group_name
  retention_in_days = var.api_access_log_retention_days
  tags              = local.default_tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lab.id
  name        = "$default"
  auto_deploy = true
  tags        = local.default_tags

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLatency         = "$context.responseLatency"
      integrationLatency      = "$context.integrationLatency"
      integrationStatus       = "$context.integrationStatus"
      integrationErrorMessage = "$context.integrationErrorMessage"
      sourceIp                = "$context.identity.sourceIp"
    })
  }
}

resource "aws_lambda_permission" "allow_api_gateway_invoke_backend" {
  statement_id  = "AllowHttpApiInvokeLab006Backend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lab.execution_arn}/*/*"
}
