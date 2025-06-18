resource "aws_route53_health_check" "api_health_check" {
  for_each = toset(var.regions)
  
  fqdn                            = module.api_gateway_regional[each.key].api_domain_name
  port                            = 443
  type                            = "HTTPS"
  resource_path                   = "/health"
  failure_threshold               = "3"
  request_interval                = "30"
  cloudwatch_logs_region          = each.key
  cloudwatch_alarm_region         = each.key
  insufficient_data_health_status = "Failure"

  tags = {
    Name = "${var.env}-${var.api_name}-${each.key}-health-check"
  }
}

resource "aws_route53_record" "api_latency_routing" {
  for_each = toset(var.regions)
  
  zone_id = var.route53_zone_id
  name    = var.env == "prod" ? var.api_domain : "${var.env}.${var.api_domain}"
  type    = "A"
  
  set_identifier = each.key
  
  latency_routing_policy {
    region = each.key
  }
  
  health_check_id = aws_route53_health_check.api_health_check[each.key].id

  alias {
    name                   = module.api_gateway_regional[each.key].api_domain_cloudfront_domain_name
    zone_id                = module.api_gateway_regional[each.key].api_domain_cloudfront_zone_id
    evaluate_target_health = true
  }
}