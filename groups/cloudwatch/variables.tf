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
# Alarm configuration
# ------------------------------------------------------------------------------
variable "availability_alarm_threshold" {
  type        = number
  default     = 99
  description = "Availability percentage below which a service alarm enters ALARM state."

  validation {
    condition     = var.availability_alarm_threshold >= 0 && var.availability_alarm_threshold <= 100
    error_message = "The availability alarm threshold must be between 0 and 100."
  }
}

variable "error_rate_alarm_threshold" {
  type        = number
  default     = 1
  description = "Target 5xx error-rate percentage above which a service alarm enters ALARM state."

  validation {
    condition     = var.error_rate_alarm_threshold >= 0 && var.error_rate_alarm_threshold <= 100
    error_message = "The error-rate alarm threshold must be between 0 and 100."
  }
}

variable "cloudwatch_alarm_actions" {
  type        = list(string)
  default     = []
  description = "CloudWatch alarm action ARNs, such as SNS topics, for alarm notifications."
}

variable "cloudwatch_alarm_ok_actions" {
  type        = list(string)
  default     = []
  description = "CloudWatch alarm action ARNs for recovery notifications."
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
