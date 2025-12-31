# LexiInfra - Infrastructure as Code

Terraform configuration for deploying the LexiEnglish AI Learning Platform.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     VPC (10.0.0.0/16)                   │   │
│  │  ┌───────────────┐  ┌────────────────┐                  │   │
│  │  │ Public Subnet │  │ Private Subnet │                  │   │
│  │  │   (ALB, NAT)  │  │ (ECS, RDS, EC) │                  │   │
│  │  └───────────────┘  └────────────────┘                  │   │
│  │                                                          │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐   │   │
│  │  │ LexiBE  │  │ LexiFE  │  │ LexiAI  │  │ RDS PG   │   │   │
│  │  │  (ECS)  │  │  (ECS)  │  │  (ECS)  │  │ (Aurora) │   │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └──────────┘   │   │
│  │                                                          │   │
│  │  ┌──────────────┐  ┌───────────┐  ┌─────────────────┐   │   │
│  │  │ ElastiCache  │  │    S3     │  │   CloudWatch    │   │   │
│  │  │   (Redis)    │  │ (uploads) │  │  (Monitoring)   │   │   │
│  │  └──────────────┘  └───────────┘  └─────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured
- S3 bucket for state (create manually)

## Quick Start

```bash
# Initialize
cd environments/dev
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

## Directory Structure

```
lexi-infra/
├── modules/
│   ├── vpc/          # VPC, subnets, NAT
│   ├── ecs/          # ECS cluster, services
│   ├── rds/          # Aurora PostgreSQL
│   ├── elasticache/  # Redis
│   ├── s3/           # File storage
│   └── monitoring/   # CloudWatch, alerts
├── environments/
│   ├── dev/
│   └── prod/
└── global/
    └── iam/
```

## Environments

| Environment | Domain | 
|-------------|--------|
| dev | dev.lexienglish.com |
| prod | lexienglish.com |
