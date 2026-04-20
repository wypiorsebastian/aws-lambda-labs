output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)."
  value       = aws_apigatewayv2_api.lab.api_endpoint
}

output "public_url" {
  description = "Publiczna trasa bez autoryzacji."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/public"
}

output "profile_url" {
  description = "Chroniona trasa używająca custom Lambda authorizera."
  value       = "${aws_apigatewayv2_api.lab.api_endpoint}/profile"
}

output "authorizer_name" {
  description = "Nazwa funkcji Lambda będącej authorizerem."
  value       = aws_lambda_function.authorizer.function_name
}

output "business_function_name" {
  description = "Nazwa funkcji backendowej obsługującej API."
  value       = aws_lambda_function.business.function_name
}
