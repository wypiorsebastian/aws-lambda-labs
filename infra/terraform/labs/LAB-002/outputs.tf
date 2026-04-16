output "api_base_url" {
  value = aws_apigatewayv2_api.feature_flags.api_endpoint
}

output "flags_collection_url" {
  value = "${aws_apigatewayv2_api.feature_flags.api_endpoint}/flags"
}

output "sample_flag_url" {
  value = "${aws_apigatewayv2_api.feature_flags.api_endpoint}/flags/beta-dashboard"
}

output "default_probe_url" {
  value = "${aws_apigatewayv2_api.feature_flags.api_endpoint}/this-route-does-not-exist"
}
