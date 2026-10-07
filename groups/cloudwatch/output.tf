# output "ecs_clusters" {
#   value       = data.aws_ecs_clusters.clusters
#   description = "List of ECS clusters"
# }

# output "ecs_services" {
#   value = {
#     for name, service in data.aws_ecs_service.services : name => service.arn
#   }
#   description = "ARNs of the ECS services"
# }

# output "ecs_service_target_groups" {
#   value = {
#     for service_name, service in data.aws_ecs_service.services : service_name => [
#       for load_balancer in service.load_balancer : {
#         arn                = load_balancer.target_group_arn
#         name               = data.aws_lb_target_group.service_target_groups[load_balancer.target_group_arn].name
#         arn_suffix         = data.aws_lb_target_group.service_target_groups[load_balancer.target_group_arn].arn_suffix
#         load_balancer_arns = data.aws_lb_target_group.service_target_groups[load_balancer.target_group_arn].load_balancer_arns
#       }
#       if load_balancer.target_group_arn != null && load_balancer.target_group_arn != ""
#     ]
#   }
#   description = "Target groups associated with each ECS service"
# }

# output "ecs_service_log_groups" {
#   value = {
#     for service_name, log_group_names in local.service_log_group_names : service_name => [
#       for name in log_group_names : {
#         arn  = data.aws_cloudwatch_log_group.service_logs[name].arn
#       }
#     ]
#   }
#   description = "CloudWatch log groups configured for each ECS service"
# }