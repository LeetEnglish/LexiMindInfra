# Dev Environment

terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "lexi-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "lexi-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "LexiEnglish"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

# Variables
variable "aws_region" {
  default = "ap-southeast-1"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "be_image" {
  default = "ghcr.io/lexienglish/lexi-mind-be:latest"
}

variable "fe_image" {
  default = "ghcr.io/lexienglish/lexi-mind-fe:latest"
}

variable "ai_image" {
  default = "ghcr.io/lexienglish/lexi-ai:latest"
}

# ==================== Modules ====================

module "vpc" {
  source = "../../modules/vpc"

  project_name       = "lexi-english"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
}

module "s3" {
  source = "../../modules/s3"

  project_name = "lexi-english"
  environment  = "dev"
}

module "rds" {
  source = "../../modules/rds"

  project_name          = "lexi-english"
  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
  db_name               = "lexienglish"
  db_username           = var.db_username
  db_password           = var.db_password
  instance_class        = "db.t3.micro"
}

module "elasticache" {
  source = "../../modules/elasticache"

  project_name          = "lexi-english"
  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
  node_type             = "cache.t3.micro"
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = "lexi-english"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  be_image           = var.be_image
  fe_image           = var.fe_image
  ai_image           = var.ai_image
  be_cpu             = 256
  be_memory          = 512
  fe_cpu             = 256
  fe_memory          = 512
  ai_cpu             = 512
  ai_memory          = 1024
  db_host            = module.rds.db_host
  redis_host         = module.elasticache.redis_endpoint
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name     = "lexi-english"
  environment      = "dev"
  ecs_cluster_name = module.ecs.ecs_cluster_name
  alb_arn_suffix   = module.ecs.alb_dns_name
}

# ==================== Outputs ====================

output "alb_dns" {
  value = module.ecs.alb_dns_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "s3_bucket" {
  value = module.s3.bucket_name
}
