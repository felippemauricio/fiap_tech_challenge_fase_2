variable "environment" {
  type = string
}

variable "catalog_database_name" {
  type = string
}

variable "tables" {
  type = list(object({
    name       = string
    table_type = string
    location   = string
    parameters = optional(map(string), {
      classification       = "parquet"
      useGlueParquetWriter = "true"
    })
    columns = list(object({
      name = string
      type = string
    }))
    partition_keys = list(object({
      name = string
      type = string
    }))
  }))
}
