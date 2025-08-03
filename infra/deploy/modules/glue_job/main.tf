locals {
  rendered_glue_script = templatefile("${path.root}/jobs/glue-job-visual-base.json.tpl", {
    glue_job_name                 = var.glue_job_name
    iam_role_arn                  = var.iam_role_arn
    s3_bucket                     = "glue-job-scripts-${var.glue_job_name}"
    s3_bucket_name_read_and_write = var.s3_bucket_name_read_and_write
    glue_catalog_database         = var.glue_catalog_database
    environment                   = var.environment
  })
}

resource "aws_s3_bucket" "s3_glue_script_bucket" {
  bucket = "glue-job-scripts-${var.glue_job_name}"

  tags = {
    Name        = "glue-job-scripts-${var.glue_job_name}"
    Environment = var.environment
  }
}

resource "aws_s3_object" "s3_glue_script" {
  bucket  = aws_s3_bucket.s3_glue_script_bucket.bucket
  key     = "${var.glue_job_name}/${var.glue_job_name}.json"
  content = local.rendered_glue_script
  etag    = md5(local.rendered_glue_script)

  depends_on = [
    aws_s3_bucket.s3_glue_script_bucket
  ]
}
