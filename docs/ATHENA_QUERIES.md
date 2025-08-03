# 📊 Athena SQL Query Examples

This guide provides practical SQL queries to explore and analyze B3 trading data using Amazon Athena.

## 🧭 Overview

The B3 trading dataset is partitioned by `year`, `month`, and `day`, and split across daily and monthly aggregation tables.

This guide is structured by **analytical goal**, rather than by table, for easier navigation and use in notebooks, dashboards, or ad-hoc queries.

## 📅 1. Filtering and Inspecting Daily Data

Use these queries to explore raw data for a specific day or filter by asset and asset type.

### 1.1 Query Daily Snapshot

```sql
SELECT 
  code,
  asset_name,
  date_partition,
  type,
  format('%,d', theorical_qty) AS theorical_qty,
  format('%,d', part) AS part
FROM "b3-trading-catalog-database-prod"."trading-daily-table-prod"
WHERE 
  year = '2025' AND 
  month = '08' AND 
  day = '01'
ORDER BY code;
```

### 1.2 Filter by Asset

```sql
SELECT 
  code,
  asset_name,
  date_partition,
  type,
  format('%,d', theorical_qty) AS theorical_qty,
  format('%,d', part) AS part
FROM "b3-trading-catalog-database-prod"."trading-daily-table-prod"
WHERE 
  year = '2025' AND 
  month = '08' AND 
  day = '01' AND
  code = 'ABEV3'
ORDER BY code;
```

### 1.3 Group by Type

```sql
SELECT 
  type,
  date_partition,
  format('%,d', SUM(theorical_qty)) AS theorical_qty,
  format('%,d', SUM(part)) AS part
FROM "b3-trading-catalog-database-prod"."trading-daily-table-prod"
WHERE 
  year = '2025' AND 
  month = '08' AND 
  day = '01'
GROUP BY 
  type, 
  date_partition
ORDER BY type;
```

## 📈 2. Aggregation Over Time

Use these queries to observe totals and patterns aggregated by day or by month.

### 2.1 Daily Aggregated Totals

```sql
SELECT
  CONCAT(year, '-', month, '-', day) AS full_date,
  format('%,d', total_theorical_qty) AS total_theorical_qty,
  format('%,d', total_part) AS total_part
FROM "b3-trading-catalog-database-prod"."trading-daily-agg-table-prod"
ORDER BY year, month, day;
```

### 2.2 Monthly Aggregated Totals

```sql
SELECT *
FROM "b3-trading-catalog-database-prod"."trading-monthly-agg-table-prod"
WHERE 
  year = '2025' AND 
  month = '08'
ORDER BY code;
```

## 🔄 3. Comparative Analysis

Compare daily values with monthly aggregates to identify changes or outliers.

### 3.1 Join Daily and Monthly Data

```sql
SELECT 
  daily.code,
  daily.asset_name,
  daily.date_partition,
  
  format('%,d', daily.theorical_qty) AS theorical_qty,
  format('%,.2f', monthly.avg_theorical_qty) AS monthly_avg_theorical_qty,
  format('%,d', monthly.min_theorical_qty) AS monthly_min_theorical_qty,
  format('%,d', monthly.max_theorical_qty) AS monthly_max_theorical_qty,
  
  format('%,d', daily.part) AS part,
  format('%,.2f', monthly.avg_part) AS monthly_avg_part,
  format('%,d', monthly.min_part) AS monthly_min_part,
  format('%,d', monthly.max_part) AS monthly_max_part

FROM "b3-trading-catalog-database-prod"."trading-daily-table-prod" AS daily
LEFT JOIN "b3-trading-catalog-database-prod"."trading-monthly-agg-table-prod" AS monthly
  ON daily.code = monthly.code
  AND daily.year = monthly.year
  AND daily.month = monthly.month
WHERE 
  daily.year = '2025' AND 
  daily.month = '08' AND 
  daily.day = '01'
ORDER BY daily.code;
```

### 3.2 Status Comparison (Daily vs Monthly)

```sql
SELECT 
  daily.code,
  daily.asset_name,
  daily.date_partition,
  
  format('%,d', daily.part) AS part,
  format('%,d', monthly.min_part) AS monthly_min_part,
  format('%,d', monthly.max_part) AS monthly_max_part,
  
  CASE 
    WHEN daily.part > monthly.min_part THEN 'UP'
    WHEN daily.part < monthly.min_part THEN 'DOWN'
    ELSE 'SAME'
  END AS status_part
FROM "b3-trading-catalog-database-prod"."trading-daily-table-prod" AS daily
LEFT JOIN "b3-trading-catalog-database-prod"."trading-monthly-agg-table-prod" AS monthly
  ON daily.code = monthly.code
  AND daily.year = monthly.year
  AND daily.month = monthly.month
WHERE 
  daily.year = '2025' AND 
  daily.month = '08' AND 
  daily.day = '01'
ORDER BY daily.code;
```

## 🎥 AWS Athena Query Execution Demo

![Athena Query](images/athena-query.gif)

---

## 📘 Notes

- Replace `"b3-trading-catalog-database-<ENVIRONMENT>"` with your environment-specific catalog/database name used in Step 5 (e.g., `-prod`, `-dev`, etc.).
- Always use `year`, `month`, and `day` filters for optimal query performance — Athena uses partition pruning.
- The `format` functions in the examples are used only for readability (e.g., showing `1,000,000` instead of `1000000`). Feel free to remove them for numeric processing.
