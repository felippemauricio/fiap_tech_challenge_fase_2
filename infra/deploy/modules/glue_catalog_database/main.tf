resource "aws_glue_catalog_database" "catalog_database" {
  name = var.catalog_database_name
}

resource "aws_glue_catalog_table" "table" {
  for_each = { for tbl in var.tables : tbl.name => tbl }

  database_name = aws_glue_catalog_database.catalog_database.name
  name          = each.value.name
  table_type    = each.value.table_type
  parameters    = each.value.parameters

  dynamic "partition_keys" {
    for_each = each.value.partition_keys
    content {
      name = partition_keys.value.name
      type = partition_keys.value.type
    }
  }

  storage_descriptor {
    location      = each.value.location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    dynamic "columns" {
      for_each = each.value.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
}
