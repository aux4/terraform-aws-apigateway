locals {
  api_name = "${var.env}-${var.api_name}"
}

provider "aws" {
  for_each = toset(var.regions)
  alias    = each.key
  region   = each.key
}

module "api_gateway_regional" {
  source = "./regional"
  
  for_each = toset(var.regions)
  
  providers = {
    aws = aws[each.key]
  }
  
  region                    = each.key
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
