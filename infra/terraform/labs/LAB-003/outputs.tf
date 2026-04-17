output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)"
  value       = aws_apigatewayv2_api.config_demo.api_endpoint
}

output "config_url" {
  description = "URL do walidacji GET /config"
  value       = "${aws_apigatewayv2_api.config_demo.api_endpoint}/config"
}

output "secret_arn" {
  description = "ARN sekretu w Secrets Manager (wrażliwe — nie loguj w aplikacji produkcyjnej bez potrzeby)"
  value       = aws_secretsmanager_secret.app.arn
  sensitive   = true
}

output "lambda_function_name" {
  description = "Nazwa funkcji Lambda (log group / konsola)"
  value       = aws_lambda_function.config_demo.function_name
}
