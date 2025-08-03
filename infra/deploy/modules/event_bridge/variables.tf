variable "environment" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "scheduler_name" {
  type = string
}

variable "scheduler_expression" {
  type = string
}

variable "schedule_expression_timezone" {
  type    = string
  default = "America/Sao_Paulo"
}
