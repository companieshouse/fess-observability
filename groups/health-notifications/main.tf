resource "aws_cloudwatch_event_rule" "console" {
  name        = "aws-health-events"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    source = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_events.arn
}