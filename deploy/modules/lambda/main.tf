resource "aws_ecr_repository" "lambda_repo" {
  name = var.ecr_repository_name

  tags = {
    Env  = var.environment
    Name = var.ecr_repository_name
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  role          = var.iam_role_arn
  package_type  = "Image"
  architectures = ["arm64"]
  image_uri     = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  timeout       = 120

  environment {
    variables = var.environment_variables
  }
}
