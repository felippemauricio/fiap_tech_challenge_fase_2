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
  lambda_name   = "b3_trading_scraper_lambda_${var.environment}"
  iam_role_arn  = data.aws_iam_role.labrole_iam_role.arn
  path_code_zip = "${path.root}/package/b3_trading_scraper.zip"
}
