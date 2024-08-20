resource "aws_api_gateway_domain_name" "api_domain" {
  certificate_arn = aws_acm_certificate_validation.api_certificate_validation.certificate_arn
  domain_name     = var.env == "prod" ? var.api_domain : "${var.env}.${var.api_domain}"
}

resource "aws_route53_record" "api_domain_route" {
  name    = aws_api_gateway_domain_name.api_domain.domain_name
  type    = "A"
  zone_id = var.route53_zone_id
  allow_overwrite = true

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}
