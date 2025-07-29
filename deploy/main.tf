provider "aws" {
  region = var.aws_region
}

data "aws_iam_role" "labrole_iam_role" {
  name = "LabRole"
}

module "s3_b3_trading_scraper" {
  source      = "./modules/s3"
  bucket_name = "b3-trading-scraper-data-${var.environment}"
  environment = var.environment
}

module "lambda_b3_trading_scraper" {
  source        = "./modules/lambda"
  lambda_name   = "b3-trading-scraper-lambda-${var.environment}"
  iam_role_arn  = data.aws_iam_role.labrole_iam_role.arn
  path_code_zip = "${path.root}/package/b3_trading_scraper.zip"
}

module "event_bridge_trading_scraper" {
  source               = "./modules/event_bridge"
  scheduler_expression = "cron(0 * * * ? *)"
  scheduler_name       = "b3-trading-scraper-scheduler-hourly"
  iam_role_arn         = data.aws_iam_role.labrole_iam_role.arn
  lambda_arn           = module.lambda_b3_trading_scraper.lambda_function.arn
}
