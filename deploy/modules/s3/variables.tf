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

variable "s3_folders" {
  type    = list(string)
  default = []
}

variable "enable_versioning" {
  type    = bool
  default = false
}
