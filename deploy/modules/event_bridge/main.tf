resource "aws_scheduler_schedule" "scheduler" {
  name                         = var.scheduler_name
  schedule_expression          = var.scheduler_expression
  schedule_expression_timezone = "America/Sao_Paulo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.lambda_arn
    role_arn = var.iam_role_arn

    input = jsonencode({
      source         = "eventbridge-scheduler",
      scheduled_time = "<aws.scheduler.scheduled-time>"
    })
  }
}
