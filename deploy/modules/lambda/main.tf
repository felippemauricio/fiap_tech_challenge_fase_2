resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  handler          = var.handler
  runtime          = "python3.11"
  filename         = var.path_code_zip
  role             = var.iam_role_arn
  source_code_hash = filebase64sha256(var.path_code_zip)
  timeout          = 60

  environment {
    variables = var.environment_variables
  }
}
