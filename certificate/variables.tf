variable "region" {
  description = "The AWS region for this certificate"
  type        = string
}

variable "env" {
  description = "The environment"
  type        = string
}

variable "api_domain" {
  description = "The domain of the API Gateway"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID"
  type        = string
}