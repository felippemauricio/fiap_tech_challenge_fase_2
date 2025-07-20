variable "aws_region" {
  type    = string
  default = "us-east-1" # N. Virginia
}

variable "aws_account_id" {
  type    = string
  default = "467807053936"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "s3_bucket_name" {
  type    = string
  default = "b3-trading-data-scraper"
}
