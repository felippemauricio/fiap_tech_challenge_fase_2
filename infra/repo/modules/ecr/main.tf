resource "aws_ecr_repository" "ecr_repository" {
  name = var.ecr_repository_name

  tags = {
    Env  = var.environment
    Name = var.ecr_repository_name
  }
}
