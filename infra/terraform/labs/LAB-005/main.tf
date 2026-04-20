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
  api_name                 = "custom-authorizer-api-lab005"
  authorizer_function_name = "custom-authorizer-lab005"
  business_function_name   = "business-api-lab005"

  authorizer_zip_path = "${path.module}/../../../../artifacts/LAB-005/authorizer-function.zip"
  business_zip_path   = "${path.module}/../../../../artifacts/LAB-005/business-function.zip"

  # TODO(lab-005): dopasuj handlery do realnych namespace/klas w swoich projektach.
  authorizer_handler = "Lab005Authorizer::Lab005Authorizer.Function::FunctionHandler"
  business_handler   = "Lab005Business::Lab005Business.Function::FunctionHandler"

  default_tags = merge(
    var.lab_tags,
    { Lab = "LAB-005" }
  )
}

resource "aws_iam_role" "authorizer_exec" {
  name = "${local.authorizer_function_name}-exec-role"

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

resource "aws_iam_role_policy_attachment" "authorizer_basic_execution" {
  role       = aws_iam_role.authorizer_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "authorizer" {
  name              = "/aws/lambda/${local.authorizer_function_name}"
  retention_in_days = 14
  tags              = local.default_tags
}

resource "aws_lambda_function" "authorizer" {
  function_name = local.authorizer_function_name
  role          = aws_iam_role.authorizer_exec.arn

  filename         = local.authorizer_zip_path
  source_code_hash = filebase64sha256(local.authorizer_zip_path)

  handler = local.authorizer_handler
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 256

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.authorizer_basic_execution,
    aws_cloudwatch_log_group.authorizer
  ]
}

resource "aws_iam_role" "business_exec" {
  name = "${local.business_function_name}-exec-role"

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

resource "aws_iam_role_policy_attachment" "business_basic_execution" {
  role       = aws_iam_role.business_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "business" {
  name              = "/aws/lambda/${local.business_function_name}"
  retention_in_days = 14
  tags              = local.default_tags
}

resource "aws_lambda_function" "business" {
  function_name = local.business_function_name
  role          = aws_iam_role.business_exec.arn

  filename         = local.business_zip_path
  source_code_hash = filebase64sha256(local.business_zip_path)

  handler = local.business_handler
  runtime = "dotnet8"

  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 256

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.business_basic_execution,
    aws_cloudwatch_log_group.business
  ]
}

resource "aws_apigatewayv2_api" "lab" {
  name          = local.api_name
  protocol_type = "HTTP"
  tags          = local.default_tags
}

resource "aws_apigatewayv2_integration" "business" {
  api_id = aws_apigatewayv2_api.lab.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.business.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "custom" {
  api_id           = aws_apigatewayv2_api.lab.id
  name             = "lab005-custom-authorizer"
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.authorizer.invoke_arn
  identity_sources = ["$request.header.Authorization"]

  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  authorizer_result_ttl_in_seconds  = var.authorizer_cache_ttl_seconds
}

resource "aws_apigatewayv2_route" "public" {
  api_id    = aws_apigatewayv2_api.lab.id
  route_key = "GET /public"
  target    = "integrations/${aws_apigatewayv2_integration.business.id}"
}

resource "aws_apigatewayv2_route" "profile" {
  api_id             = aws_apigatewayv2_api.lab.id
  route_key          = "GET /profile"
  target             = "integrations/${aws_apigatewayv2_integration.business.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.custom.id
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lab.id
  name        = "$default"
  auto_deploy = true
  tags        = local.default_tags
}

resource "aws_lambda_permission" "allow_api_gateway_business" {
  statement_id  = "AllowHttpApiInvokeLab005Business"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.business.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lab.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_authorizer" {
  statement_id  = "AllowHttpApiInvokeLab005Authorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lab.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.custom.id}"
}
