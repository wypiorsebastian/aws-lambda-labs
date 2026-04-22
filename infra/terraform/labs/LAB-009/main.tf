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
  lab_id            = "LAB-009"
  function_name     = "lab009-image-function"
  api_name          = "lab009-image-http-api"
  ecr_repo_name     = "lab009-lambda-image"
  lambda_image_uri  = "${aws_ecr_repository.lambda.repository_url}:${var.image_tag}"

  default_tags = merge(
    var.lab_tags,
    { Lab = local.lab_id }
  )
}

resource "aws_ecr_repository" "lambda" {
  name                 = local.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.default_tags
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

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.lambda_log_retention_days
  tags              = local.default_tags
}

resource "aws_lambda_function" "backend" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_exec.arn

  package_type = "Image"
  image_uri    = local.lambda_image_uri

  timeout      = 15
  memory_size  = 256
  architectures = ["x86_64"]

  environment {
    variables = {
      LAB_ID = local.lab_id
    }
  }

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
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

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lab.id
  name        = "$default"
  auto_deploy = true
  tags        = local.default_tags
}

resource "aws_lambda_permission" "allow_api_gateway_invoke_backend" {
  statement_id  = "AllowHttpApiInvokeLab009Backend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lab.execution_arn}/*/*"
}
