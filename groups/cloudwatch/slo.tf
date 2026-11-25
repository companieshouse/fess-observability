resource "awscc_applicationsignals_service_level_objective" "service_slo" {
  for_each    = local.service_slos
  name        = "${each.key}"

  # Set up a period-based SLI
  request_based_sli = each.value.kind == "availability" ? {
    request_based_sli_metric = {
      total_request_count_metric = local.service_slo_queries[each.key].requests
      monitored_request_count_metric = {
        bad_count_metric = local.service_slo_queries[each.key].errors
      }
    }
  } : null

  sli = each.value.kind == "latency" ? {
    comparison_operator = "LessThan"
    metric_threshold    = each.value.threshold
    sli_metric = { metric_data_queries = local.service_slo_queries[each.key].latency }
  } : null

  goal = {
    attainment_goal   = each.value.target
    interval = { rolling_interval = { duration = 30, duration_unit = "DAY" } }
  }

  # Add burn rate configurations
  burn_rate_configurations = [
    {
      look_back_window_minutes = 5
    },
    {
      look_back_window_minutes = 60
    },
    {
      look_back_window_minutes = 360
    }
  ]

  # Add tags
  tags = [
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "Service",
      value = each.value.service
    },
    {
      key   = "Team"
      value = "FESS"
    },
    {
      key   = "ManagedBy"
      value = "terraform"
    }
  ]
}