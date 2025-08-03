{
	"jobConfig": {
		"name": "${glue_job_name}",
		"description": "",
		"role": "${iam_role_arn}",
		"command": "glueetl",
		"version": "5.0",
		"runtime": null,
		"workerType": "G.1X",
		"numberOfWorkers": 2,
		"maxCapacity": 2,
		"jobRunQueuingEnabled": true,
		"maxRetries": 0,
		"timeout": 2880,
		"maxConcurrentRuns": 1,
		"security": "none",
		"scriptName": "${glue_job_name}.py",
		"scriptLocation": "s3://${s3_bucket}/scripts/",
		"language": "python-3",
		"spark": true,
		"sparkConfiguration": "standard",
		"jobParameters": [],
		"tags": [],
		"jobMode": "VISUAL_MODE",
		"createdOn": "2025-07-31T13:11:07.022Z",
		"developerMode": false,
		"connectionsList": [],
		"temporaryDirectory": "s3://${s3_bucket}/temporary/",
		"glueHiveMetastore": true,
		"etlAutoTuning": true,
		"metrics": true,
		"observabilityMetrics": true,
		"pythonPath": "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_common.py,s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_array_to_cols.py,s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_split.py",
		"bookmark": "job-bookmark-disable",
		"sparkPath": "s3://${s3_bucket}/sparkHistoryLogs/",
		"flexExecution": false,
		"minFlexWorkers": null,
		"maintenanceWindow": null,
		"dependentPath": "",
		"additionalPythonModules": ""
	},
	"dag": {
		"node-1754015925296": {
			"nodeId": "node-1754015925296",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1753967516885"
			],
			"name": "rename_code",
			"generatedNodeName": "rename_code_node1754015925296",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "cod",
			"targetPath": "code",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1753967516885": {
			"nodeId": "node-1753967516885",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [],
			"name": "trading_raw_data",
			"generatedNodeName": "trading_raw_data_node1753967516885",
			"classification": "DataSource",
			"type": "S3",
			"isCatalog": false,
			"format": "parquet",
			"paths": [
				"s3://${s3_bucket_name_read_and_write}/raw_data/"
			],
			"compressionType": null,
			"exclusions": [],
			"groupFiles": null,
			"groupSize": null,
			"recurse": true,
			"maxBand": null,
			"maxFilesInBand": null,
			"additionalOptions": {
				"boundedSize": null,
				"boundedFiles": null,
				"enableSamplePath": false,
				"samplePath": "s3://${s3_bucket_name_read_and_write}/raw_data/year=2025/month=07/day=30/ibovespa.parquet",
				"boundedOption": null
			},
			"outputSchemas": [
				[
					{
						"key": "cod",
						"fullPath": [
							"cod"
						],
						"type": "string"
					},
					{
						"key": "asset",
						"fullPath": [
							"asset"
						],
						"type": "string"
					},
					{
						"key": "type",
						"fullPath": [
							"type"
						],
						"type": "string"
					},
					{
						"key": "part",
						"fullPath": [
							"part"
						],
						"type": "long"
					},
					{
						"key": "raw_type",
						"fullPath": [
							"raw_type"
						],
						"type": "string"
					},
					{
						"key": "raw_theorical_qty",
						"fullPath": [
							"raw_theorical_qty"
						],
						"type": "string"
					},
					{
						"key": "theorical_qty",
						"fullPath": [
							"theorical_qty"
						],
						"type": "long"
					},
					{
						"key": "raw_part",
						"fullPath": [
							"raw_part"
						],
						"type": "string"
					},
					{
						"key": "date_partition",
						"fullPath": [
							"date_partition"
						],
						"type": "string"
					},
					{
						"key": "extract_timestamp",
						"fullPath": [
							"extract_timestamp"
						],
						"type": "string"
					}
				]
			],
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754023756808": {
			"nodeId": "node-1754023756808",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754024027994"
			],
			"name": "refined_daily",
			"generatedNodeName": "refined_daily_node1754023756808",
			"classification": "DataSink",
			"type": "S3",
			"streamingBatchInterval": 100,
			"format": "glueparquet",
			"compression": "snappy",
			"numberTargetPartitions": "0",
			"path": "s3://${s3_bucket_name_read_and_write}/refined/daily/",
			"partitionKeys": [
				"year",
				"month",
				"day",
				"code"
			],
			"schemaChangePolicy": {
				"enableUpdateCatalog": true,
				"updateBehavior": "LOG",
				"database": "${glue_catalog_database}",
				"table": "trading-daily-table-${environment}"
			},
			"updateCatalogOptions": "partitions",
			"autoDataQuality": {
				"isEnabled": true,
				"evaluationContext": "EvaluateDataQuality_node1754015576604"
			},
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754120351629": {
			"nodeId": "node-1754120351629",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754024027994"
			],
			"name": "date_partition_to_date",
			"generatedNodeName": "date_partition_to_date_node1754120351629",
			"classification": "Transform",
			"type": "ApplyMapping",
			"mapping": [
				{
					"toKey": "type",
					"fromPath": [
						"type"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "part",
					"fromPath": [
						"part"
					],
					"toType": "long",
					"fromType": "bigint",
					"dropped": false
				},
				{
					"toKey": "raw_type",
					"fromPath": [
						"raw_type"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "raw_theorical_qty",
					"fromPath": [
						"raw_theorical_qty"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "theorical_qty",
					"fromPath": [
						"theorical_qty"
					],
					"toType": "long",
					"fromType": "bigint",
					"dropped": false
				},
				{
					"toKey": "raw_part",
					"fromPath": [
						"raw_part"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "date_partition",
					"fromPath": [
						"date_partition"
					],
					"toType": "date",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "extract_timestamp",
					"fromPath": [
						"extract_timestamp"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "code",
					"fromPath": [
						"code"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "asset_name",
					"fromPath": [
						"asset_name"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "year",
					"fromPath": [
						"year"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "month",
					"fromPath": [
						"month"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				},
				{
					"toKey": "day",
					"fromPath": [
						"day"
					],
					"toType": "string",
					"fromType": "string",
					"dropped": false,
					"children": null
				}
			],
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754116892413": {
			"nodeId": "node-1754116892413",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029194203"
			],
			"name": "refined_daily_agg",
			"generatedNodeName": "refined_daily_agg_node1754116892413",
			"classification": "DataSink",
			"type": "S3",
			"streamingBatchInterval": 100,
			"format": "glueparquet",
			"compression": "snappy",
			"numberTargetPartitions": "0",
			"path": "s3://${s3_bucket_name_read_and_write}/refined/daily_agg/",
			"partitionKeys": [
				"year",
				"month",
				"day"
			],
			"schemaChangePolicy": {
				"enableUpdateCatalog": true,
				"updateBehavior": "LOG",
				"database": "${glue_catalog_database}",
				"table": "trading-daily-agg-table-${environment}"
			},
			"updateCatalogOptions": "partitions",
			"autoDataQuality": {
				"isEnabled": true,
				"evaluationContext": "EvaluateDataQuality_node1754115192667"
			},
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754120854581": {
			"nodeId": "node-1754120854581",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754120808308"
			],
			"name": "rename_max_date_partition",
			"generatedNodeName": "rename_max_date_partition_node1754120854581",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "max(date_partition)",
			"targetPath": "max_date_partition",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754117581115": {
			"nodeId": "node-1754117581115",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754121382511"
			],
			"name": "refined_monthly_agg",
			"generatedNodeName": "refined_monthly_agg_node1754117581115",
			"classification": "DataSink",
			"type": "S3",
			"streamingBatchInterval": 100,
			"format": "glueparquet",
			"compression": "snappy",
			"numberTargetPartitions": "0",
			"path": "s3://${s3_bucket_name_read_and_write}/refined/monthly_agg/",
			"partitionKeys": [
				"year",
				"month",
				"code"
			],
			"schemaChangePolicy": {
				"enableUpdateCatalog": true,
				"updateBehavior": "LOG",
				"database": "${glue_catalog_database}",
				"table": "trading-monthly-agg-table-${environment}"
			},
			"updateCatalogOptions": "partitions",
			"autoDataQuality": {
				"isEnabled": true,
				"evaluationContext": "EvaluateDataQuality_node1754117508913"
			},
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754016098358": {
			"nodeId": "node-1754016098358",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754015925296"
			],
			"name": "rename_asset_name",
			"generatedNodeName": "rename_asset_name_node1754016098358",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "asset",
			"targetPath": "asset_name",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754028719008": {
			"nodeId": "node-1754028719008",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754024027994"
			],
			"name": "agg_year_month_day",
			"generatedNodeName": "agg_year_month_day_node1754028719008",
			"classification": "Transform",
			"type": "Aggregate",
			"parentsValid": true,
			"calculatedType": "",
			"groups": [
				"year",
				"month",
				"day"
			],
			"aggs": [
				{
					"column": "theorical_qty",
					"aggFunc": "sum"
				},
				{
					"column": "part",
					"aggFunc": "sum"
				}
			],
			"codeGenVersion": 2
		},
		"node-1754029811354": {
			"nodeId": "node-1754029811354",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029745837"
			],
			"name": "rename_avg_part",
			"generatedNodeName": "rename_avg_part_node1754029811354",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "avg(part)",
			"targetPath": "avg_part",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754120892886": {
			"nodeId": "node-1754120892886",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754120854581"
			],
			"name": "custom_add_date_partition_diff",
			"generatedNodeName": "custom_add_date_partition_diff_node1754120892886",
			"classification": "Transform",
			"type": "CustomCode",
			"code": "from awsglue.dynamicframe import DynamicFrame\nfrom pyspark.sql.functions import datediff, col\n\ndf = dfc.select(list(dfc.keys())[0]).toDF()\ndf = df.withColumn(\"diff_date_partition\", datediff(col(\"max_date_partition\"), col(\"min_date_partition\")))\nreturn DynamicFrameCollection({\"CustomTransform0\": DynamicFrame.fromDF(df, glueContext, \"CustomTransform0\")}, glueContext)",
			"className": "MyTransform",
			"outputSchemas": [
				[
					{
						"key": "year",
						"fullPath": [
							"year"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "month",
						"fullPath": [
							"month"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "code",
						"fullPath": [
							"code"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "avg_theorical_qty",
						"fullPath": [
							"avg_theorical_qty"
						],
						"type": "double",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "avg_part",
						"fullPath": [
							"avg_part"
						],
						"type": "double",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "min_part",
						"fullPath": [
							"min_part"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "max_part",
						"fullPath": [
							"max_part"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "min_theorical_qty",
						"fullPath": [
							"min_theorical_qty"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "max_theorical_qty",
						"fullPath": [
							"max_theorical_qty"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "min_date_partition",
						"fullPath": [
							"min_date_partition"
						],
						"type": "date",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "max_date_partition",
						"fullPath": [
							"max_date_partition"
						],
						"type": "date",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "diff_date_partition",
						"fullPath": [
							"diff_date_partition"
						],
						"type": "int",
						"glueStudioType": null,
						"children": null
					}
				]
			],
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029745837": {
			"nodeId": "node-1754029745837",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029281362"
			],
			"name": "rename_avg_theorical_qty",
			"generatedNodeName": "rename_avg_theorical_qty_node1754029745837",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "avg(theorical_qty)",
			"targetPath": "avg_theorical_qty",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029890115": {
			"nodeId": "node-1754029890115",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029811354"
			],
			"name": "rename_min_part",
			"generatedNodeName": "rename_min_part_node1754029890115",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "min(part)",
			"targetPath": "min_part",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754030012476": {
			"nodeId": "node-1754030012476",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029972556"
			],
			"name": "rename_max_theorical_qty",
			"generatedNodeName": "rename_max_theorical_qty_node1754030012476",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "max(theorical_qty)",
			"targetPath": "max_theorical_qty",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754028903434": {
			"nodeId": "node-1754028903434",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754028719008"
			],
			"name": "rename_total_theorical_qty",
			"generatedNodeName": "rename_total_theorical_qty_node1754028903434",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "sum(theorical_qty)",
			"targetPath": "total_theorical_qty",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754121382511": {
			"nodeId": "node-1754121382511",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754120892886"
			],
			"name": "select_collection",
			"generatedNodeName": "select_collection_node1754121382511",
			"classification": "Transform",
			"type": "SelectFromCollection",
			"index": 0,
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754017825693": {
			"nodeId": "node-1754017825693",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754017688127"
			],
			"name": "add_year_month_day",
			"generatedNodeName": "add_year_month_day_node1754017825693",
			"classification": "Transform",
			"type": "DynamicTransform",
			"parameters": [
				{
					"name": "colName",
					"value": [
						"date_partition_array"
					],
					"isOptional": false,
					"type": "str",
					"listType": null
				},
				{
					"name": "colList",
					"value": [
						"year,month,day"
					],
					"isOptional": false,
					"type": "str",
					"listType": null
				}
			],
			"functionName": "gs_array_to_cols",
			"path": "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_array_to_cols.py",
			"version": "1.0.0",
			"transformName": "gs_array_to_cols",
			"outputSchemas": [
				[
					{
						"key": "type",
						"fullPath": [
							"type"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "part",
						"fullPath": [
							"part"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_type",
						"fullPath": [
							"raw_type"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_theorical_qty",
						"fullPath": [
							"raw_theorical_qty"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "theorical_qty",
						"fullPath": [
							"theorical_qty"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_part",
						"fullPath": [
							"raw_part"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "date_partition",
						"fullPath": [
							"date_partition"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "extract_timestamp",
						"fullPath": [
							"extract_timestamp"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "code",
						"fullPath": [
							"code"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "asset_name",
						"fullPath": [
							"asset_name"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "date_partition_array",
						"fullPath": [
							"date_partition_array"
						],
						"type": "string array",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "year",
						"fullPath": [
							"year"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "month",
						"fullPath": [
							"month"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "day",
						"fullPath": [
							"day"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					}
				]
			],
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754120808308": {
			"nodeId": "node-1754120808308",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754030012476"
			],
			"name": "rename_min_date_partition",
			"generatedNodeName": "rename_min_date_partition_node1754120808308",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "min(date_partition)",
			"targetPath": "min_date_partition",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029930326": {
			"nodeId": "node-1754029930326",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029890115"
			],
			"name": "rename_max_part",
			"generatedNodeName": "rename_max_part_node1754029930326",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "max(part)",
			"targetPath": "max_part",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754024027994": {
			"nodeId": "node-1754024027994",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754017825693"
			],
			"name": "drop_date_partition_array",
			"generatedNodeName": "drop_date_partition_array_node1754024027994",
			"classification": "Transform",
			"type": "DropFields",
			"paths": [
				"date_partition_array"
			],
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029281362": {
			"nodeId": "node-1754029281362",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754120351629"
			],
			"name": "agg_year_month_code",
			"generatedNodeName": "agg_year_month_code_node1754029281362",
			"classification": "Transform",
			"type": "Aggregate",
			"parentsValid": true,
			"calculatedType": "",
			"groups": [
				"year",
				"month",
				"code"
			],
			"aggs": [
				{
					"column": "theorical_qty",
					"aggFunc": "avg"
				},
				{
					"column": "part",
					"aggFunc": "avg"
				},
				{
					"column": "part",
					"aggFunc": "min"
				},
				{
					"column": "part",
					"aggFunc": "max"
				},
				{
					"column": "theorical_qty",
					"aggFunc": "min"
				},
				{
					"column": "theorical_qty",
					"aggFunc": "max"
				},
				{
					"column": "date_partition",
					"aggFunc": "min"
				},
				{
					"column": "date_partition",
					"aggFunc": "max"
				}
			],
			"codeGenVersion": 2
		},
		"node-1754017688127": {
			"nodeId": "node-1754017688127",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754016098358"
			],
			"name": "split_date_partition",
			"generatedNodeName": "split_date_partition_node1754017688127",
			"classification": "Transform",
			"type": "DynamicTransform",
			"parameters": [
				{
					"name": "colName",
					"value": [
						"date_partition"
					],
					"isOptional": false,
					"type": "str",
					"listType": null
				},
				{
					"name": "pattern",
					"value": [
						"-"
					],
					"isOptional": false,
					"type": "str",
					"listType": null
				},
				{
					"name": "newColName",
					"value": [
						"date_partition_array"
					],
					"isOptional": true,
					"type": "str",
					"listType": null
				}
			],
			"functionName": "gs_split",
			"path": "s3://aws-glue-studio-transforms-510798373988-prod-us-east-1/gs_split.py",
			"version": "1.0.0",
			"transformName": "gs_split",
			"outputSchemas": [
				[
					{
						"key": "type",
						"fullPath": [
							"type"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "part",
						"fullPath": [
							"part"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_type",
						"fullPath": [
							"raw_type"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_theorical_qty",
						"fullPath": [
							"raw_theorical_qty"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "theorical_qty",
						"fullPath": [
							"theorical_qty"
						],
						"type": "bigint",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "raw_part",
						"fullPath": [
							"raw_part"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "date_partition",
						"fullPath": [
							"date_partition"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "extract_timestamp",
						"fullPath": [
							"extract_timestamp"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "code",
						"fullPath": [
							"code"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "asset_name",
						"fullPath": [
							"asset_name"
						],
						"type": "string",
						"glueStudioType": null,
						"children": null
					},
					{
						"key": "date_partition_array",
						"fullPath": [
							"date_partition_array"
						],
						"type": "string array",
						"glueStudioType": null,
						"children": null
					}
				]
			],
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029194203": {
			"nodeId": "node-1754029194203",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754028903434"
			],
			"name": "rename_total_part",
			"generatedNodeName": "rename_total_part_node1754029194203",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "sum(part)",
			"targetPath": "total_part",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		},
		"node-1754029972556": {
			"nodeId": "node-1754029972556",
			"dataPreview": false,
			"previewAmount": 0,
			"inputs": [
				"node-1754029930326"
			],
			"name": "rename_min_theorical_qty",
			"generatedNodeName": "rename_min_theorical_qty_node1754029972556",
			"classification": "Transform",
			"type": "RenameField",
			"sourcePath": "min(theorical_qty)",
			"targetPath": "min_theorical_qty",
			"parentsValid": true,
			"calculatedType": "",
			"codeGenVersion": 2
		}
	},
	"hasBeenSaved": false,
	"usageProfileName": null
}