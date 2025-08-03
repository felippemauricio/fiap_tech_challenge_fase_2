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
### Repositories
######################################

module "ecr_b3_trading_scraper" {
  source              = "./modules/ecr"
  ecr_repository_name = "fiap/b3-trading-scraper-${var.environment}"
  environment         = var.environment
}

module "ecr_trigger_glue_etl" {
  source              = "./modules/ecr"
  ecr_repository_name = "fiap/trigger-glue-etl-${var.environment}"
  environment         = var.environment
}
