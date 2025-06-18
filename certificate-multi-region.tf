module "certificate_regional" {
  source = "./certificate"
  
  for_each = toset(var.regions)
  
  providers = {
    aws = local.region_providers[each.key]
  }
  
  region          = each.key
  env             = var.env
  api_domain      = var.api_domain
  route53_zone_id = var.route53_zone_id
}