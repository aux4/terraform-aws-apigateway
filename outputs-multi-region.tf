output "api_gateway_regional_ids" {
  description = "Map of regional API Gateway IDs"
  value       = { for alias, _ in var.region_providers : alias => module.api_gateway_regional[alias].api_gateway_id }
}

output "api_gateway_regional_arns" {
  description = "Map of regional API Gateway ARNs"
  value       = { for alias, _ in var.region_providers : alias => module.api_gateway_regional[alias].api_gateway_arn }
}

output "api_gateway_regional_execution_arns" {
  description = "Map of regional API Gateway execution ARNs"
  value       = { for alias, _ in var.region_providers : alias => module.api_gateway_regional[alias].api_gateway_execution_arn }
}

output "api_gateway_regional_invoke_urls" {
  description = "Map of regional API Gateway invoke URLs"
  value       = { for alias, _ in var.region_providers : alias => module.api_gateway_regional[alias].api_gateway_invoke_url }
}

output "api_regional_domain_names" {
  description = "Map of regional domain names"
  value       = { for alias, _ in var.region_providers : alias => module.api_gateway_regional[alias].api_domain_name }
}

output "api_primary_domain_name" {
  description = "Primary domain name with latency-based routing"
  value       = var.env == "prod" ? var.api_domain : "${var.env}.${var.api_domain}"
}

output "route53_health_check_ids" {
  description = "Map of Route 53 health check IDs for each region"
  value       = { for alias, _ in var.region_providers : alias => aws_route53_health_check.api_health_check[alias].id }
}

output "certificate_arns" {
  description = "Map of ACM certificate ARNs for each region"
  value       = { for alias, _ in var.region_providers : alias => module.certificate_regional[alias].certificate_arn }
}

output "regions" {
  description = "Map of provider aliases to actual AWS regions"
  value       = { for alias, _ in var.region_providers : alias => data.aws_region.current[alias].name }
}