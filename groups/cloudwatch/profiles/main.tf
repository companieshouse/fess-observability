resource "aws_cloudwatch_dashboard" "service" {

  dashboard_name = "fess-observability-terraform-test"
  dashboard_body = templatefile("${path.module}/templates/dashboard.json.tmpl", {})
}