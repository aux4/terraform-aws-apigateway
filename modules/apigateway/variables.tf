variable "env" {
  description = "The environment"
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
      zip                   = string
      file                  = string
      runtime               = string
      memory_size           = number
      timeout               = number
      environment_variables = map(string)
      policies              = list(string)
      log_retention         = number
    })
    authorizer_result_ttl_in_seconds = number
  })))
}

variable "api_paths" {
  description = "The paths for the API Gateway"
  type = map(map(object({
    security = list(map(string))
    lambda = object({
      zip                   = string
      file                  = string
      runtime               = string
      memory_size           = number
      timeout               = number
      environment_variables = map(string)
      policies              = list(string)
      log_retention         = number
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

