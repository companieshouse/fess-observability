# ------------------------------------------------------------------------------
# Environmental configuration
# ------------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "The environment name, defined in envrionments vars."
}

variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "The AWS region for deployment."
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use for deployment."
}

# ------------------------------------------------------------------------------
# Service configuration
# ------------------------------------------------------------------------------
variable "service_name" {
  type        = string
  description = "The user friendly service name used to name AWS resources."
}