variable "env" {
  description = "The environment"
  type        = string
}

variable "function_prefix" {
  description = "The prefix of the Lambda function"
  type        = string
  default     = ""
  nullable    = false
}

variable "function_runtime" {
  description = "The runtime of the Lambda function"
  type        = string
  default     = "nodejs20.x"
  nullable    = false
}

variable "function_memory_size" {
  description = "The memory size of the Lambda function"
  type        = number
  default     = 128
  nullable    = false
}

variable "function_timeout" {
  description = "The timeout of the Lambda function"
  type        = number
  default     = 3
  nullable    = false
}

variable "function_file" {
  description = "The file name of the Lambda function"
  type        = string
  nullable    = false
}

variable "function_zip" {
  description = "The zip file of the Lambda function"
  type        = string
  default     = "../dist/api.zip"
  nullable    = false
}

variable "function_environment_variables" {
  description = "The environment variables for the Lambda function"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "function_policies" {
  description = "The policies for the Lambda function"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "function_log_retention" {
  description = "The log retention for the Lambda function"
  type        = number
  default     = 14
  nullable    = false
}
