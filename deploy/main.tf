provider "aws" {
  region = var.aws_region
}

######################################
### Role LabRole
######################################

data "aws_iam_role" "labrole_iam_role" {
  name = "LabRole"
}

######################################
### B3 Trading Scraper
######################################

module "s3_b3_trading_scraper" {
  source                          = "./modules/s3"
  bucket_name                     = "b3-trading-scraper-data-${var.environment}"
  environment                     = var.environment
  bucket_notification_lambda_name = module.lambda_trigger_glue_etl.lambda_function.function_name
}

module "lambda_b3_trading_scraper" {
  source        = "./modules/lambda"
  lambda_name   = "b3-trading-scraper-lambda-${var.environment}"
  iam_role_arn  = data.aws_iam_role.labrole_iam_role.arn
  path_code_zip = "${path.root}/package/b3_trading_scraper.zip"

  environment_variables = {
    ENV              = var.environment
    S3_BUCKET        = module.s3_b3_trading_scraper.bucket.bucket
    S3_BUCKET_FOLDER = "raw_data"
  }
}

module "event_bridge_b3_trading_scraper" {
  source               = "./modules/event_bridge"
  scheduler_expression = "cron(0 * * * ? *)" # hourly
  scheduler_name       = "b3-trading-scraper-scheduler-hourly"
  iam_role_arn         = data.aws_iam_role.labrole_iam_role.arn
  lambda_arn           = module.lambda_b3_trading_scraper.lambda_function.arn
}

######################################
### GLUE ETL
######################################

module "lambda_trigger_glue_etl" {
  source        = "./modules/lambda"
  lambda_name   = "trigger-glue-etl-lambda-${var.environment}"
  iam_role_arn  = data.aws_iam_role.labrole_iam_role.arn
  path_code_zip = "${path.root}/package/trigger-glue-etl.zip"

  environment_variables = {
    ENV = var.environment
  }
}

resource "aws_s3_bucket_notification" "invoke_lambda_trigger_glue_etl_on_object_created" {
  bucket = module.s3_b3_trading_scraper.bucket.bucket

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = module.lambda_trigger_glue_etl.lambda_function.arn
    filter_prefix       = "raw_data/"
    filter_suffix       = ".parquet"
  }

  depends_on = [
    module.s3_b3_trading_scraper,
    module.s3_b3_trading_scraper.bucket_lambda_permission,
    module.lambda_trigger_glue_etl
  ]
}
