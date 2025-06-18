variable "region" {
  description = "The AWS region for this deployment"
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

variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_prefix" {
  description = "The name of the API Gateway"
  type        = string
  default     = ""
  nullable    = false
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = ""
  nullable    = false
}

variable "api_authorizers" {
  description = "The authorizers for the API Gateway"
  type        = map(object({
    type = string
    lambda = object({
      arn                   = optional(string)
      zip                   = optional(string)
      file                  = optional(string)
      runtime               = optional(string)
      memory_size           = optional(number)
      timeout               = optional(number)
      environment_variables = optional(map(string))
      policies              = optional(list(string))
      log_retention         = optional(number)
    })
    authorizer_result_ttl_in_seconds = optional(number)
  }))
  
  validation {
    condition = alltrue([
      for auth in var.api_authorizers : contains(["bearer", "cookie"], auth.type)
    ])
    error_message = "Authorizer type must be either 'bearer' or 'cookie'."
  }
}

variable "api_paths" {
  description = "The paths for the API Gateway"
  type = map(map(object({
    security = optional(list(string))
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

variable "api_cors_allowed_origins" {
  description = "List of allowed origins for CORS. If not provided, defaults to '*'"
  type        = list(string)
  default     = ["*"]
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the domain"
  type        = string
}