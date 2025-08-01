resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "s3_bucket_folders" {
  for_each = toset(var.s3_folders)

  bucket  = var.bucket_name
  key     = "${each.value}/_keep"
  content = ""
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  count         = var.bucket_notification_lambda_name != "" ? 1 : 0
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.bucket_notification_lambda_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket.arn
}
