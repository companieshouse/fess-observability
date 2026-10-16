resource "aws_sns_topic" "observability_alerts" {
  name = "fess-observability-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.observability_alerts.arn
  protocol  = "https"
  endpoint  = local.xmatters_webhook_url
}

resource "aws_cloudwatch_metric_alarm" "availability" {
  for_each = local.service_alarm_target_groups

  alarm_name          = "fess-observability-${var.environment}-${each.key}-availability"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.availability_alarm_threshold
  alarm_description   = format("Service availability is below %.2f%% for %s.", var.availability_alarm_threshold, each.key)
  treat_missing_data  = "notBreaching"
  alarm_actions       = concat(var.cloudwatch_alarm_actions, [aws_sns_topic.observability_alerts.arn])
  ok_actions          = var.cloudwatch_alarm_ok_actions

  metric_query {
    id          = "request_total"
    expression  = "SUM(METRICS(\"requests_\"))"
    return_data = false
  }

  metric_query {
    id          = "error_total"
    expression  = "SUM(METRICS(\"errors_\"))"
    return_data = false
  }

  metric_query {
    id          = "availability"
    expression  = "100 * (request_total - error_total) / request_total"
    label       = "Availability (%)"
    return_data = true
  }

  dynamic "metric_query" {
    for_each = {
      for index, target_group in each.value : "requests_${index}" => target_group
    }

    content {
      id          = metric_query.key
      return_data = false

      metric {
        metric_name = "RequestCount"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = metric_query.value.load_balancer_arn_suffix
          TargetGroup  = metric_query.value.arn_suffix
        }
      }
    }
  }

  dynamic "metric_query" {
    for_each = {
      for index, target_group in each.value : "errors_${index}" => target_group
    }

    content {
      id          = metric_query.key
      return_data = false

      metric {
        metric_name = "HTTPCode_Target_5XX_Count"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = metric_query.value.load_balancer_arn_suffix
          TargetGroup  = metric_query.value.arn_suffix
        }
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  for_each = local.service_alarm_target_groups

  alarm_name          = "fess-observability-${var.environment}-${each.key}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.error_rate_alarm_threshold
  alarm_description   = format("Service target 5xx error rate is above %.2f%% for %s.", var.error_rate_alarm_threshold, each.key)
  treat_missing_data  = "notBreaching"
  alarm_actions       = concat(var.cloudwatch_alarm_actions, [aws_sns_topic.observability_alerts.arn])
  ok_actions          = var.cloudwatch_alarm_ok_actions

  metric_query {
    id          = "request_total"
    expression  = "SUM(METRICS(\"requests_\"))"
    return_data = false
  }

  metric_query {
    id          = "error_total"
    expression  = "SUM(METRICS(\"errors_\"))"
    return_data = false
  }

  metric_query {
    id          = "error_rate"
    expression  = "100 * error_total / request_total"
    label       = "Error rate (%)"
    return_data = true
  }

  dynamic "metric_query" {
    for_each = {
      for index, target_group in each.value : "requests_${index}" => target_group
    }

    content {
      id          = metric_query.key
      return_data = false

      metric {
        metric_name = "RequestCount"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = metric_query.value.load_balancer_arn_suffix
          TargetGroup  = metric_query.value.arn_suffix
        }
      }
    }
  }

  dynamic "metric_query" {
    for_each = {
      for index, target_group in each.value : "errors_${index}" => target_group
    }

    content {
      id          = metric_query.key
      return_data = false

      metric {
        metric_name = "HTTPCode_Target_5XX_Count"
        namespace   = "AWS/ApplicationELB"
        period      = 300
        stat        = "Sum"
        dimensions = {
          LoadBalancer = metric_query.value.load_balancer_arn_suffix
          TargetGroup  = metric_query.value.arn_suffix
        }
      }
    }
  }
}