output "bucket" {
  value = aws_s3_bucket.s3_bucket
}

output "bucket_lambda_permission" {
  value = aws_lambda_permission.allow_s3_to_invoke_lambda
}
