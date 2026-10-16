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

  service_alarm_target_groups = {
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
