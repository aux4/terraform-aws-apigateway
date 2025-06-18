terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  api_name_multi = "${var.env}-${var.api_name}"
}

# Use data source to get current region for each provider
data "aws_region" "current" {
  for_each = var.region_providers
  provider = aws[each.key]
}

module "certificate_regional" {
  source = "./certificate"
  
  for_each = var.region_providers
  
  providers = {
    aws = aws[each.key]
  }
  
  region          = data.aws_region.current[each.key].name
  env             = var.env
  api_domain      = var.api_domain
  route53_zone_id = var.route53_zone_id
}

module "api_gateway_regional" {
  source = "./regional"
  
  for_each = var.region_providers
  
  providers = {
    aws = aws[each.key]
  }
  
  region                    = data.aws_region.current[each.key].name
  env                      = var.env
  api_name                 = var.api_name
  api_prefix               = var.api_prefix
  api_description          = var.api_description
  api_authorizers          = var.api_authorizers
  api_paths                = var.api_paths
  api_log_retention        = var.api_log_retention
  api_binary_media_types   = var.api_binary_media_types
  api_cors_allowed_origins = var.api_cors_allowed_origins
  api_domain               = var.api_domain
  certificate_arn          = module.certificate_regional[each.key].certificate_arn
}

resource "aws_route53_health_check" "api_health_check" {
  for_each = var.region_providers
  
  fqdn                            = module.api_gateway_regional[each.key].api_domain_name
  port                            = 443
  type                            = "HTTPS"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_logs_region          = data.aws_region.current[each.key].name
  cloudwatch_alarm_region         = data.aws_region.current[each.key].name
  insufficient_data_health_status = "Failure"

  tags = {
    Name = "${var.env}-${var.api_name}-${data.aws_region.current[each.key].name}-health-check"
  }
}

resource "aws_route53_record" "api_latency_routing" {
  for_each = var.region_providers
  
  zone_id = var.route53_zone_id
  name    = var.env == "prod" ? var.api_domain : "${var.env}.${var.api_domain}"
  type    = "A"
  
  set_identifier = data.aws_region.current[each.key].name
  
  latency_routing_policy {
    region = data.aws_region.current[each.key].name
  }
  
  health_check_id = aws_route53_health_check.api_health_check[each.key].id

  alias {
    name                   = module.api_gateway_regional[each.key].api_domain_cloudfront_domain_name
    zone_id                = module.api_gateway_regional[each.key].api_domain_cloudfront_zone_id
    evaluate_target_health = true
  }
}