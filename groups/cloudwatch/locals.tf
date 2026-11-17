locals {
  vault_secret_path = "applications/${var.aws_profile}/${var.environment}/fess/monitoring"

  xmatters_webhook_url = format(
    "https://%s%s",
    var.xmatters_host,
    jsondecode(data.vault_generic_secret.secrets.data_json).xmatters_endpoint
  )

  service_configs = [
    {
      name    = "dissolution-api"
      cluster = "filing-close"
    },
    {
      name    = "dissolution-web"
      cluster = "filing-close"
    },
    {
      name    = "insolvency-api"
      cluster = "filing-close"
    },
    {
      name    = "advanced-company-search-consumer"
      cluster = "search-service"
    },
    {
      name    = "auth-code-notification"
      cluster = "search-service"
    },
    {
      name    = "chs-streaming-api"
      cluster = "streaming"
    },
    {
      name    = "strike-off-objections-api"
      cluster = "company-requests"
    },
    {
      name    = "strike-off-objections-web"
      cluster = "company-requests"
    },
    {
      name    = "strike-off-partner-objections-api"
      cluster = "company-requests"
    },
    {
      name    = "strike-off-partner-objections-processor"
      cluster = "company-requests"
    },
    {
      name    = "certified-copies-orders-api"
      cluster = "order-service"
    },
    {
      name    = "frontend-document-api"
      cluster = "document"
    },
    {
      name    = "backend-document-api"
      cluster = "document"
    },
    {
      name    = "emergency-auth-code-api"
      cluster = "identity"
    },
    {
      name = "authentication-service"
      cluster = "identity"
      slo = {
        availability = {
          enabled = true,
          target  = 99.5,
          period  = 60
        }
        latency = {
          enabled = true,
          target = 99.5,
          period  = 60,
          threshold = 0.5 # 500ms latency threshold
        }
      }
    }
  ]

  service_slos = merge([
    for service in local.service_configs : {
      for kind, config in try(service.slo, {}) :
      "${var.environment}-${service.name}-${kind}" => merge(config, {
        service = service.name
        kind    = kind
      }) if try(config.enabled, false)
    }
  ]...)

  slo_metrics = {
    availability = {
      requests = {
        name       = "RequestCount"
        stat       = "Sum"
        expression = "SUM(METRICS(\"requests_\"))"
      }
      errors = {
        name       = "HTTPCode_Target_5XX_Count"
        stat       = "Sum"
        expression = "SUM(METRICS(\"errors_\"))"
      }
    }
    latency = {
      latency = {
        name       = "TargetResponseTime"
        stat       = "p95"
        expression = "MAX(METRICS(\"latency_\"))"
      }
    }
  }

  service_slo_queries = {
    for key, slo in local.service_slos : key => {
      for metric_id, metric in local.slo_metrics[slo.kind] : metric_id => concat(
        [
          for index, target in local.service_slo_target_groups[slo.service] : {
            id          = "${metric_id}_${index}"
            return_data = false
            metric_stat = {
              period = slo.period
              stat   = metric.stat
              metric = {
                namespace   = "AWS/ApplicationELB"
                metric_name = metric.name
                dimensions = [
                  { name = "LoadBalancer", value = target.load_balancer_arn_suffix },
                  { name = "TargetGroup", value = target.arn_suffix }
                ]
              }
            }
          }
        ],
        [
          {
            id          = "${metric_id}_value"
            expression  = metric.expression
            return_data = true
          }
        ]
      )
    }
  }

  service_log_group_names = {
    for service_name, task_definition in data.aws_ecs_task_definition.services : service_name => distinct([
      for container in jsondecode(task_definition.container_definitions) :
      try(container.logConfiguration.options["awslogs-group"], null)
      if try(container.logConfiguration.logDriver, null) == "awslogs" && try(container.logConfiguration.options["awslogs-group"], null) != null
    ])
  }

  service_log_group_arns = {
    for service_name, log_group_names in local.service_log_group_names : service_name => [
      for name in log_group_names :
      data.aws_cloudwatch_log_group.service_logs[name].arn
    ]
  }

  service_slo_target_groups = {
    for service_name, service in data.aws_ecs_service.services : service_name => [
      for target_group_arn in toset([
        for load_balancer in service.load_balancer : load_balancer.target_group_arn
        if load_balancer.target_group_arn != null && load_balancer.target_group_arn != ""
        ]) : {
        arn_suffix = data.aws_lb_target_group.service_target_groups[target_group_arn].arn_suffix
        load_balancer_arn_suffix = split(
          ":loadbalancer/",
          one(data.aws_lb_target_group.service_target_groups[target_group_arn].load_balancer_arns)
        )[1]
      }
    ]
    if length([
      for load_balancer in service.load_balancer : load_balancer.target_group_arn
      if load_balancer.target_group_arn != null && load_balancer.target_group_arn != ""
    ]) > 0
  }
}