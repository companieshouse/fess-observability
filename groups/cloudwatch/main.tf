resource "aws_cloudwatch_dashboard" "target_group" {

  dashboard_name = "fess-observability-terraform-target-group-test"
  dashboard_body = templatefile("${path.module}/templates/target-group.json.tmpl", {
    testing = ""
  })
}

resource "aws_cloudwatch_dashboard" "ecs_service" {
  dashboard_name = "fess-observability-terraform-ecs-service-test"
  dashboard_body = templatefile("${path.module}/templates/service.json.tmpl", {})
}
resource "aws_cloudwatch_dashboard" "observability" {
  for_each = data.aws_ecs_service.services

  dashboard_name = "fess-observability-${var.environment}-${each.key}"
  dashboard_body = templatefile("${path.module}/templates/observability.json.tmpl", {
    region       = var.aws_region
    service_name = each.value.service_name
    cluster_name = basename(each.value.cluster_arn)
    task_cpu     = data.aws_ecs_task_definition.services[each.key].cpu
    task_memory  = data.aws_ecs_task_definition.services[each.key].memory
    container_definitions = jsondecode(
      data.aws_ecs_task_definition.services[each.key].container_definitions
    )
    target_groups = [
      for target_group_arn in toset([
        for load_balancer in each.value.load_balancer : load_balancer.target_group_arn
        if load_balancer.target_group_arn != null && load_balancer.target_group_arn != ""
        ]) : {
        name       = data.aws_lb_target_group.service_target_groups[target_group_arn].name
        arn_suffix = data.aws_lb_target_group.service_target_groups[target_group_arn].arn_suffix
        load_balancer_arn_suffix = split(
          ":loadbalancer/",
          one(data.aws_lb_target_group.service_target_groups[target_group_arn].load_balancer_arns)
        )[1]
      }
    ]
    log_group_names = local.service_log_group_names[each.key]
    log_group_arns = local.service_log_group_arns[each.key]
  })
}