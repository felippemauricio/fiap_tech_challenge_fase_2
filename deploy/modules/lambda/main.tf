resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  handler          = var.handler
  runtime          = "python3.11"
  filename         = var.path_code_zip
  role             = var.iam_role_arn
  source_code_hash = filebase64sha256(var.path_code_zip)
  timeout          = 60
}

# resource "aws_cloudwatch_event_rule" "every_hour" {
#   name                = "trigger-b3-scraper-hourly"
#   schedule_expression = "rate(1 hour)"
# }

# resource "aws_lambda_permission" "allow_eventbridge" {
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.scraper.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.every_hour.arn
# }

# # Faz o binding entre EventBridge e Lambda
# resource "aws_cloudwatch_event_target" "send_to_lambda" {
#   rule      = aws_cloudwatch_event_rule.every_hour.name
#   target_id = "b3-scraper-lambda"
#   arn       = aws_lambda_function.scraper.arn
# }
