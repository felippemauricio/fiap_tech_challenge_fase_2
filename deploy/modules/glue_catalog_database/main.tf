resource "aws_glue_catalog_database" "catalog_database" {
  name = var.catalog_database_name
}
