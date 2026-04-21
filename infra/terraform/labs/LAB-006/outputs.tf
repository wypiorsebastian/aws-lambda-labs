output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)."
  value       = aws_apigatewayv2_api.lab.api_endpoint
}

output "health_url" {
  description = "URL trasy health check."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/health"
}

output "order_url_example" {
  description = "Przykładowy URL trasy biznesowej."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/orders/ord-123"
}

output "fail_url" {
  description = "URL trasy do kontrolowanego scenariusza błędu."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/fail"
}

output "lambda_function_name" {
  description = "Nazwa funkcji Lambda backendowej."
  value       = aws_lambda_function.backend.function_name
}

output "lambda_log_group_name" {
  description = "Nazwa grupy logów CloudWatch dla Lambdy."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "api_access_log_group_name" {
  description = "Nazwa grupy access logów API Gateway."
  value       = aws_cloudwatch_log_group.api_access.name
}
