resource "aws_athena_workgroup" "athena_workgroup" {
  name = var.workgroup_name

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = var.output_location
    }
  }

  tags = {
    Environment = var.environment
  }
}
