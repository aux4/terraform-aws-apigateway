terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [
        aws.us-east-1,
        aws.us-west-2,
        aws.eu-west-1,
        aws.ap-southeast-1,
      ]
    }
  }
}

locals {
  api_name_multi = "${var.env}-${var.api_name}"
  
  # Provider mapping for common regions
  region_providers = {
    "us-east-1"      = aws.us-east-1
    "us-west-2"      = aws.us-west-2
    "eu-west-1"      = aws.eu-west-1
    "ap-southeast-1" = aws.ap-southeast-1
  }
}

module "api_gateway_regional" {
  source = "./regional"
  
  for_each = toset(var.regions)
  
  providers = {
    aws = local.region_providers[each.key]
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
