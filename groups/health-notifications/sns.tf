resource "aws_sns_topic" "aws_events" {
    name = "aws-events"
}

resource "aws_sns_topic_policy" "aws_events" {
    arn = aws_sns_topic.aws_events.arn
    policy = data.aws_iam_policy_document.aws_events_sns_policy.json
}

resource "aws_sns_topic_subscription" "aws_events" {
    topic_arn = aws_sns_topic.aws_events.arn
    protocol  = "https"
    endpoint  = local.xmatters_webhook_url
}