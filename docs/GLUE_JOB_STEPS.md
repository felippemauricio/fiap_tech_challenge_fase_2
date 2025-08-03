# 🧠 Glue Job: Step-by-Step Breakdown

This document explains the internal logic of the **AWS Glue Visual Job** for B3 trading data processing. The job is defined visually using a sequence of nodes in AWS Glue Studio.

## 🔄 Overview

The job performs the following:

- Reads raw Parquet files from S3 (partitioned by `year/month/day`)
- Cleans and standardizes fields
- Calculates new columns (e.g., parsed dates)
- Writes the transformed data back to another S3 path, partitioned and ready for Athena

## 🧩 Step-by-Step Nodes

### 1. 🟢 **S3 Source**

- **Type:** S3 (Parquet)
- **Path:** `s3://<bucket>/raw_data/year=<yyyy>/month=<MM>/day=<dd>/`
- **Schema:** Auto-detected or manually mapped
- **Columns loaded:**
  - `cod`, `asset`, `type`, `part`, `theoricalQty`, `date_partition`, `extract_timestamp`

### 2. 🛠️ **Rename Fields**

- Renames some columns to more descriptive or standardized names:
  - `cod` → `code`
  - `theoricalQty` → `theorical_qty`
  - `extract_timestamp` → `ingestion_ts`

### 3. 🧮 **Apply Mapping / Transformations**

- Ensures consistent types for Athena (e.g., string, bigint)
- Parses `date_partition` into year, month, day columns
  - `year = year(date_partition)`
  - `month = month(date_partition)`
  - `day = day(date_partition)`
- Casts `part` and `theorical_qty` to integers if needed

### 4. ➕ **Add Fields**

- Adds derived columns:
  - `ingestion_date = current_date()`
  - `source = 'b3-trading'`

### 5. 🟦 **S3 Target**

- **Type:** S3 (Parquet with Hive-compatible partitioning)
- **Output Path:**  
  `s3://<bucket>/curated/trading-daily/`
- **Partitions:** `year`, `month`, `day`

## 🎯 Output

The resulting dataset is:

- Clean
- Partitioned
- Ready to query via Athena

Athena table name example:

```sql
b3-trading-catalog-database-prod.trading-daily-table-prod
```