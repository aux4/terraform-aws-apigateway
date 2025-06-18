output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

output "api_domain_name" {
  description = "Domain name of the API Gateway"
  value       = aws_api_gateway_domain_name.api_domain.domain_name
}

output "api_domain_cloudfront_domain_name" {
  description = "CloudFront domain name of the API Gateway domain"
  value       = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
}

output "api_domain_cloudfront_zone_id" {
  description = "CloudFront zone ID of the API Gateway domain"
  value       = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
}