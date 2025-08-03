# IBOVESPA Index Data Processing Job Description

This job is designed to process, validate, and aggregate daily IBOVESPA index data starting from raw Parquet files, producing tables with different aggregation levels for downstream analysis.

## 🔁 Job Workflow

### 1. Raw Data Ingestion

- Input data is stored in Parquet files partitioned by year, month, and day with the path format:  
  `year=/month=/day=/ibovespa.parquet`.
- These files are updated daily with the latest available data.

### 2. Field Normalization

- Rename the column `cod` to `code` for standardization.  
- Rename the column `asset` to `asset_name`.

### 3. Date Field Extraction

- The `date_partition` field (a date string) is split into an array with year, month, and day components.  
- These components are then transformed into three separate columns:  
  - `year`  
  - `month`  
  - `day`

### 4. Job Splitting into Three Parallel Processes

#### a) Full Daily Data Write

- Writes the processed data directly to a target S3 bucket.  
- Creates or updates the table `trading-daily-table-prod` partitioned by:  
  `year`, `month`, `day`, and `code`.  
- This table holds the complete granular dataset for each day.

#### b) Daily Aggregation

- Aggregates data daily, grouping by:  
  `year`, `month`, and `day` (excluding the asset code).  
- Computes:  
  - The sum of the `part` column (which should total 100%) to ensure data integrity.  
  - The sum of `theorical_qty`, used to verify data consistency against the official B3 website.  
- Results are saved in the aggregated daily table `trading-daily-agg-table-prod`, partitioned by:  
  `year`, `month`, and `day`.

#### c) Monthly Aggregation

- Performs monthly aggregations, grouping by:  
  `year`, `month`, and `code` (excluding day).  
- Calculates:  
  - The average `part` value over the month, representing the consolidated participation of each asset.  
  - The maximum and minimum `date_partition` values within the month.  
  - The difference between these dates to determine how many days were considered in the period.  
- Stores the aggregated results in the table `trading-monthly-agg-table-prod`, partitioned by:  
  `year`, `month`, and `code`.

## 🎥 AWS Glue Job Execution Demo

![Glue Job](images/glue-job.gif)

---

This workflow ensures well-organized, validated tables at multiple granularities, facilitating daily and monthly IBOVESPA data analysis.
