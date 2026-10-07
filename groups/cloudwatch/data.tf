data "aws_ecs_clusters" "clusters" {}

data "aws_ecs_service" "services" {
  for_each = { for service in local.service_configs : service.name => service }

  cluster_arn = one([
    for cluster_arn in data.aws_ecs_clusters.clusters.cluster_arns : cluster_arn
    if endswith(cluster_arn, "/${each.value.cluster}-${var.environment}-cluster")
  ])

  service_name = "${var.environment}-${each.value.name}"
}

data "aws_lb_target_group" "service_target_groups" {
  for_each = toset(flatten([
    for service in data.aws_ecs_service.services : [
      for load_balancer in service.load_balancer : load_balancer.target_group_arn
      if load_balancer.target_group_arn != null && load_balancer.target_group_arn != ""
    ]
  ]))

  arn = each.value
}

data "aws_ecs_task_definition" "services" {
  for_each = data.aws_ecs_service.services

  task_definition = each.value.task_definition
}

data "aws_cloudwatch_log_group" "service_logs" {
  for_each = toset(flatten(values(local.service_log_group_names)))

  name = each.value
}