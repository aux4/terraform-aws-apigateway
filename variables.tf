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

variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = ""
}

variable "api_authorizers" {
  description = "The authorizers for the API Gateway"
  type        = map(map(object({
    lambda = object({
      zip                   = optional(string)
      file                  = string
      runtime               = optional(string)
      memory_size           = optional(number)
      timeout               = optional(number)
      environment_variables = optional(map(string))
      policies              = optional(list(string))
      log_retention         = optional(number)
    })
    authorizer_result_ttl_in_seconds = optional(number)
  })))
}

variable "api_paths" {
  description = "The paths for the API Gateway"
  type = map(map(object({
    security = list(string)
    lambda = object({
      zip                   = optional(string)
      file                  = string
      runtime               = optional(string)
      memory_size           = optional(number)
      timeout               = optional(number)
      environment_variables = optional(map(string))
      policies              = optional(list(string))
      log_retention         = optional(number)
    })
  })))
}

variable "api_log_retention" {
  description = "The number of days to retain log events"
  type        = number
  default     = 7
}

variable "api_binary_media_types" {
  description = "The binary media types for the API Gateway"
  type        = list(string)
  default = [
    "application/octet-stream"
  ]
}

