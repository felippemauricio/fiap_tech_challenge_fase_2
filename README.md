# 📈 Pipeline Batch Bovespa

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)

## 🏁 Getting Started

This data pipeline extracts, processes, and analyzes daily trading data from the B3 (Brasil, Bolsa, Balcão) stock exchange.
Raw data is collected from public sources using scheduled ingestion jobs and stored in AWS S3 in partitioned Parquet format. Processing and transformations are handled via AWS Glue jobs triggered by AWS Lambda functions. Processed data is made available for querying using Amazon Athena.

The official source for the raw trading data is: [https://sistemaswebb3-listados.b3.com.br/indexPage/day/IBOV?language=pt-br](https://sistemaswebb3-listados.b3.com.br/indexPage/day/IBOV?language=pt-br)

## 📁 Project Structure

```
fiap_tech_challenge_fase_2/
├── aws/                                # Local AWS credentials configuration
│   └── credentials                     # Credentials file (copied from AWS Academy)
│
├── infra/                              # Infrastructure as Code (IaC) using Terraform
│   ├── deploy/
│   │   ├── modules/
│   │   │   ├── athena/                 # Athena table and query configurations
│   │   │   ├── event_bridge/           # EventBridge rules for scheduled triggers
│   │   │   ├── glue_catalog_database/  # Glue Data Catalog and database definitions
│   │   │   ├── lambda/                 # Lambda function deployment (e.g., ETL trigger)
│   │   │   └── s3/                     # S3 bucket definitions
│   │   ├── main.tf                     # Terraform entry point for the deploy stack
│   │   └── variables.tf                # Variable declarations for deploy modules
│   │
│   └── repo/
│       ├── modules/
│       │   └── ecr/                    # Elastic Container Registry configuration
│       ├── main.tf                     # Terraform entry point for the repo stack
│       └── variables.tf                # Variable declarations for repo modules
│
├── docs/                               # Project documentation
│
├── src/                                # Application source code
│   ├── b3-trading-scraper/             # Lambda to scrape and ingest B3 stock exchange data
│   │   ├── handler.py                  # Entry point for scraping logic - AWS Lambda
│   │   └── requirements.txt            # Python dependencies for the scraper
│   │
│   └── trigger-glue-etl/               # Lambda to trigger the AWS Glue ETL job
│       ├── handler.py                  # Entry point for triggering Glue job - AWS Lambda
│       └── requirements.txt            # Python dependencies for the Lambda
│
├── docker-compose-deploy.yml           # Docker Compose for infrastructure deployment
├── docker-compose-repo.yml             # Docker Compose for repository services
│
├── Dockerfile                          # Base Dockerfile used to build Lambda images
│
└── Makefile                            # Utility commands (build, deploy, test, etc.)

```

## 🛠️ Tech Stack

- **AWS CLI** – Used for interacting with AWS services from the command line  
- **Python 3.12+** – Main programming language for Lambdas  
- **Docker** – Containerization and image builds for Lambda functions  
- **Terraform** – Infrastructure as Code (IaC) to provision AWS resources  
- **Makefile** – Automation of common tasks (build, deploy, etc.)

## ⚙️ Installation

This project automates the creation of AWS infrastructure for B3 data ingestion and processing, using containerized Lambdas, Glue, Athena, and more.

### 1. 🐳 Install Required CLI Tools (Docker & AWS CLI)

Install the necessary tools for development and deployment: Docker and AWS CLI.

> See detailed instructions in [INSTALL.md](./docs/INSTALL.md#-1-install-required-cli-tools-docker--aws-cli)

### 2. 🔐 Setting Up AWS Credentials (via AWS Academy Lab)

Configure your AWS credentials locally so Terraform and AWS CLI can operate on your AWS account.

> Full instructions available at [INSTALL.md](./docs/INSTALL.md#-2-setting-up-aws-credentials-via-aws-academy-lab)

### 3. ☁️ Provisioning AWS Infrastructure - ECR Repositories

Initial provisioning of infrastructure for the Elastic Container Registries (ECR), which will store the Lambda Docker images.

> Detailed steps at [INSTALL.md](./docs/INSTALL.md#3-%EF%B8%8F-provisioning-aws-infrastructure---ecr-repositories)

### 4. 🚀 Build and Push Lambda Docker Images to AWS ECR

How to build Docker images locally for the Lambdas and push them to the ECR repository.

> Complete guide at [INSTALL.md](./docs/INSTALL.md#4--build-and-push-lambda-docker-images-to-aws-ecr)

### 5. ☁️ Provisioning AWS Infrastructure - Core Resources / Full Resources

After images are in ECR, provision the rest of the AWS infrastructure needed for the application (Lambdas, Glue, Athena, S3, etc).

> More information at [INSTALL.md](./docs/INSTALL.md#5-%EF%B8%8F-provisioning-aws-infrastructure---core-resources--full-resources)

### 6. 🧩 Manual Creation of AWS Glue Job

Terraform generates the Glue job JSON configuration and uploads it to an S3 bucket as part of the infrastructure setup. However, due to current limitations in both Terraform and AWS APIs:

- The AWS Glue service does **not** support creating or updating jobs with complex visual workflows (i.e., the Glue Studio visual editor with drag-and-drop nodes) programmatically.
- Terraform can only create Glue jobs in **code mode** (script-based), but many Glue jobs require visual workflows with multiple steps and transformations, which cannot be fully described by the Terraform provider.
- The AWS Console Glue Studio visual editor is the only way to **create, edit, and manage** these graphical ETL jobs.

> Steps for manual creation available at [INSTALL.md](./docs/INSTALL.md#6--manual-creation-of-aws-glue-job)

## 🧱 Architecture

## 🧠 What Does the Glue Job Do?

The AWS Glue Job executes a data transformation pipeline for B3 trading data.

> 📄 See full breakdown in [GLUE_JOB_STEPS.md](./docs/GLUE_JOB_STEPS.md)

## 📊 Athena SQL Examples

Explore and analyze B3 trading data using Amazon Athena.

- Daily raw data queries  
- Daily and monthly aggregations  
- Joins and comparative analyses  

> Full query examples available at [docs/ATHENA_QUERIES.md](./docs/ATHENA_QUERIES.md)
