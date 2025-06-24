output "api_gateway_url" {
  description = "API Gateway custom domain URL"
  value       = "https://${aws_api_gateway_domain_name.api_domain.domain_name}"
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.api.execution_arn
}