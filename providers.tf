terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider aliases for multi-region
provider "aws" {
  alias  = "primary"
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "LexiEnglish"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
