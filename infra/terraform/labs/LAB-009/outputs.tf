output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)."
  value       = aws_apigatewayv2_api.lab.api_endpoint
}

output "health_url" {
  description = "URL trasy health check."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/health"
}

output "lambda_function_name" {
  description = "Nazwa funkcji Lambda image-based."
  value       = aws_lambda_function.backend.function_name
}

output "ecr_repository_url" {
  description = "URL repozytorium ECR, do którego tagujesz i wypychasz obraz."
  value       = aws_ecr_repository.lambda.repository_url
}

output "configured_image_uri" {
  description = "Image URI skonfigurowany w Lambdzie (repo + tag)."
  value       = "${aws_ecr_repository.lambda.repository_url}:${var.image_tag}"
}
