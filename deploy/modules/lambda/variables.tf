variable "environment" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "ecr_repository_name" {
  type = string
}
