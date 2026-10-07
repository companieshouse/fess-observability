locals {
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
      name = "advanced-company-search-consumer"
      cluster = "search-service"
    },
    {
      name = "auth-code-notification"
      cluster = "search-service"
    },
    {
      name = "chs-streaming-api"
      cluster = "streaming"
    }
  ]

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
}
