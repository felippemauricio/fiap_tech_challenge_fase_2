variable "lambda_name" {
  type = string
}

variable "handler" {
  type    = string
  default = "handler.lambda_handler"
}

variable "iam_role_arn" {
  type = string
}

variable "path_code_zip" {
  type = string
}
