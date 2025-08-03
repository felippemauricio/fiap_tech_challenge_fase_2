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
  bucket_notification_lambda_name = module.lambda_trigger_glue_etl.lambda_function.function_name
  environment                     = var.environment
  enable_versioning               = true
  s3_folders = [
    "raw_data",
    "refined/daily",
    "refined/daily_agg",
    "refined/monthly_agg",
  ]
}

module "lambda_b3_trading_scraper" {
  source              = "./modules/lambda"
  lambda_name         = "b3-trading-scraper-lambda-${var.environment}"
  iam_role_arn        = data.aws_iam_role.labrole_iam_role.arn
  ecr_repository_name = "fiap/b3-trading-scraper-${var.environment}"
  environment         = var.environment

  environment_variables = {
    ENV              = var.environment
    S3_BUCKET        = module.s3_b3_trading_scraper.bucket.bucket
    S3_BUCKET_FOLDER = "raw_data"
  }
}

module "event_bridge_b3_trading_scraper" {
  source                       = "./modules/event_bridge"
  scheduler_name               = "b3-trading-scraper-scheduler-4-times-${var.environment}"
  iam_role_arn                 = data.aws_iam_role.labrole_iam_role.arn
  scheduler_expression         = "cron(0 0,6,12,18 * * ? *)" # 4-times
  schedule_expression_timezone = "America/Sao_Paulo"
  lambda_arn                   = module.lambda_b3_trading_scraper.lambda_function.arn
  environment                  = var.environment
}

######################################
### Trigger GLUE ETL
######################################

module "lambda_trigger_glue_etl" {
  source              = "./modules/lambda"
  lambda_name         = "trigger-glue-etl-lambda-${var.environment}"
  iam_role_arn        = data.aws_iam_role.labrole_iam_role.arn
  ecr_repository_name = "fiap/trigger-glue-etl-${var.environment}"
  environment         = var.environment

  environment_variables = {
    ENV              = var.environment
    GLUE_JOB_NAME    = "b3-trading-visual-job-${var.environment}"
    S3_BUCKET        = module.s3_b3_trading_scraper.bucket.bucket
    S3_BUCKET_FOLDER = "refined"
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

######################################
### GLUE JOB
######################################

module "glue_script_b3_trading" {
  source                        = "./modules/glue_job"
  environment                   = var.environment
  glue_job_name                 = "b3-trading-visual-job-${var.environment}"
  iam_role_arn                  = data.aws_iam_role.labrole_iam_role.arn
  s3_bucket_name_read_and_write = "b3-trading-scraper-data-${var.environment}"
  glue_catalog_database         = "b3-trading-catalog-database-${var.environment}"
}

######################################
### GLUE DATABASE
######################################

module "glue_catalog_database_b3_trading_scraper" {
  source                = "./modules/glue_catalog_database"
  catalog_database_name = "b3-trading-catalog-database-${var.environment}"
  environment           = var.environment
  tables = [
    {
      name       = "trading-daily-table-${var.environment}"
      table_type = "EXTERNAL_TABLE"
      location   = "s3://${module.s3_b3_trading_scraper.bucket.bucket}/refined/daily/"
      parameters = {
        classification       = "parquet"
        useGlueParquetWriter = "true"
      }
      columns = [
        { name = "type", type = "string" },
        { name = "part", type = "bigint" },
        { name = "raw_type", type = "string" },
        { name = "raw_theorical_qty", type = "string" },
        { name = "theorical_qty", type = "bigint" },
        { name = "raw_part", type = "string" },
        { name = "date_partition", type = "string" },
        { name = "extract_timestamp", type = "string" },
        { name = "asset_name", type = "string" }
      ]
      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" },
        { name = "day", type = "string" },
        { name = "code", type = "string" }
      ]
    },
    {
      name       = "trading-daily-agg-table-${var.environment}",
      table_type = "EXTERNAL_TABLE"
      location   = "s3://${module.s3_b3_trading_scraper.bucket.bucket}/refined/daily_agg/"
      parameters = {
        classification       = "parquet"
        useGlueParquetWriter = "true"
      }
      columns = [
        { name = "total_theorical_qty", type = "bigint" },
        { name = "total_part", type = "bigint" },
      ]
      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" },
        { name = "day", type = "string" },
      ]
    },
    {
      name       = "trading-monthly-agg-table-${var.environment}",
      table_type = "EXTERNAL_TABLE"
      location   = "s3://${module.s3_b3_trading_scraper.bucket.bucket}/refined/monthly_agg/"
      parameters = {
        classification       = "parquet"
        useGlueParquetWriter = "true"
      }
      columns = [
        { name = "avg_theorical_qty", type = "double" },
        { name = "avg_part", type = "double" },
        { name = "min_part", type = "bigint" },
        { name = "max_part", type = "bigint" },
        { name = "min_theorical_qty", type = "bigint" },
        { name = "max_theorical_qty", type = "bigint" },
        { name = "min_date_partition", type = "date" },
        { name = "max_date_partition", type = "date" },
        { name = "diff_date_partition", type = "int" },
      ]
      partition_keys = [
        { name = "year", type = "string" },
        { name = "month", type = "string" },
        { name = "code", type = "string" }
      ]
    },
  ]
}

######################################
### Athena
######################################

module "s3_b3_trading_athena" {
  source      = "./modules/s3"
  bucket_name = "b3-trading-athena-${var.environment}"
  environment = var.environment
}

module "athena_trading_workgroup" {
  source          = "./modules/athena"
  workgroup_name  = "b3-trading-workgroup-${var.environment}"
  output_location = "s3://${module.s3_b3_trading_athena.bucket.bucket}/"
  environment     = var.environment
}
