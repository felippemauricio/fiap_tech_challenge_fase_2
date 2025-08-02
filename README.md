# 📈 Pipeline Batch Bovespa

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)

## 🏁 Getting Started

This data pipeline extracts, processes, and analyzes daily trading data from the B3 (Brasil, Bolsa, Balcão) stock exchange.
Raw data is collected from public sources using scheduled ingestion jobs and stored in AWS S3 in partitioned Parquet format. Processing and transformations are handled via AWS Glue jobs triggered by AWS Lambda functions. Processed data is made available for querying using Amazon Athena.

The official source for the raw trading data is: [https://sistemaswebb3-listados.b3.com.br/indexPage/day/IBOV?language=pt-br](https://sistemaswebb3-listados.b3.com.br/indexPage/day/IBOV?language=pt-br)

## 📁 Project Structure

```
fiap_tech_challenge_fase_2/
├── aws/                            # Local AWS credentials configuration
│   └── credentials                 # Credentials file copied from ~/.aws/credentials
├── deploy/                         # Infrastructure as Code (IaC) using Terraform
│   ├── athena/                     # Athena tables and query configurations
│   ├── event_bridge/               # Scheduled rules and EventBridge configurations
│   ├── glue_catalog_database/      # Glue Data Catalog and database definitions
│   ├── lambda/                     # AWS Lambda functions (e.g., ETL trigger)
│   ├── s3/                         # S3 bucket configuration
│   ├── main.tf                     # Main Terraform configuration file
│   └── variables.tf                # Terraform variables definition
├── docs/                           # Project documentation
├── src/                            # Application source code
│   ├── b3-trading-scraper/         # Scraper to extract data from B3 (stock exchange)
│   │   ├── handler.py              # Main function for scraping and ingestion
│   │   └── requirements.txt        # Dependencies for the scraper
│   └── trigger-glue-etl/           # Lambda function to trigger the Glue ETL job
│       ├── handler.py              # Main function to start the ETL
│       └── requirements.txt        # Dependencies for the Lambda function
├── docker-compose.yml              # Docker service orchestration (for local setup)
├── Dockerfile                      # Docker image definition (e.g., to run the scraper)
└── Makefile                        # Utility commands for build, deployment, and setup
```

## 🛠️ Tech Stack

- **Python 3.11+** 
- **Docker**  
- **Terraform**  
- **Makefile (for automation)**

## ⚙️ Installation

### 🐳 Install Docker

```
# Windows
open https://www.docker.com/products/docker-desktop/ # Download and install Docker Desktop from the official website:
docker --version # 4. Confirm installation:

# MacOS
brew install docker --cask
```

### 🔐 AWS Credentials Setup (via AWS Academy Lab)

To allow Terraform to create resources in your AWS account, you must configure your AWS credentials locally. Follow the steps below if you're using the AWS Academy Learner Lab:

📘 Steps:
1- Log in to the AWS Academy Learner Lab.
2- Go to the "AWS Details" section of your active lab.
3- Click the "Show" button next to "AWS CLI". You will see output similar to this:
```
[default]
aws_access_key_id = ABCDEFGHIJK123456789
aws_secret_access_key = aVeryLongSecretKeyHere123456789...
aws_session_token = AnotherLongSessionToken...
```
4- Copy all that content.
5- Inside this project folder, go to the aws/ directory and create a file named credentials (if it doesn't already exist).
6- Paste the copied content into aws/credentials.

### ☁️ Running Terraform to Deploy Infrastructure

After configuring your AWS credentials, you’re ready to provision the AWS resources required for this project.

This file gives Terraform temporary access to your AWS account so it can deploy infrastructure — such as:

- S3 buckets
- Lambda functions
- Glue jobs
- Athena tables

To initialize, plan, and apply the Terraform configuration, run the following commands:
```
make init
make plan
make apply
```