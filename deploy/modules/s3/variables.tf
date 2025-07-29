variable "bucket_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "bucket_notification_lambda_name" {
  type    = string
  default = ""
}

