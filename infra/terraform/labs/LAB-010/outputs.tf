output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)."
  value       = aws_apigatewayv2_api.lab.api_endpoint
}

output "health_url" {
  description = "URL trasy health check (GET)."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/health"
}

output "lambda_function_name" {
  description = "Nazwa funkcji Lambda (custom runtime ZIP)."
  value       = aws_lambda_function.backend.function_name
}

output "lambda_runtime" {
  description = "Zadeklarowany OS-only runtime Lambda."
  value       = aws_lambda_function.backend.runtime
}

output "lambda_handler" {
  description = "Handler przekazany do Lambdy (spójny z _HANDLER w środowisku)."
  value       = aws_lambda_function.backend.handler
}
