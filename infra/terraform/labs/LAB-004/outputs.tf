output "api_base_url" {
  description = "Bazowy URL HTTP API (stage $default)."
  value       = aws_apigatewayv2_api.jwt_demo.api_endpoint
}

output "public_url" {
  description = "Publiczna trasa bez JWT."
  value       = "${aws_apigatewayv2_api.jwt_demo.api_endpoint}/public"
}

output "claims_url" {
  description = "Chroniona trasa wymagająca JWT."
  value       = "${aws_apigatewayv2_api.jwt_demo.api_endpoint}/claims"
}

output "cognito_user_pool_id" {
  description = "Identyfikator User Pool (część issuer URL)."
  value       = aws_cognito_user_pool.lab.id
}

output "cognito_app_client_id" {
  description = "App client id (audience w JWT authorizerze)."
  value       = aws_cognito_user_pool_client.http_api.id
}

output "cognito_issuer_url" {
  description = "Issuer URL użyty w JWT authorizerze."
  value       = local.cognito_issuer
}
