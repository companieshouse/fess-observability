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
# Xmatters configuration
# ------------------------------------------------------------------------------

variable "xmatters_host" {
  type        = string
  default     = "companieshouse.xmatters.com"
  description = "The Xmatters host for constructing the webhook URL."
}

variable "xmatters_group" {
  type        = string
  default     = "testgroup"
  description = "The Xmatters group to notify via the webhook."
}
