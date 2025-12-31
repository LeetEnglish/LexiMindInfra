# ==================== General ====================
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "lexi-english"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

# ==================== VPC ====================
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

# ==================== RDS ====================
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "lexienglish"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# ==================== ECS ====================
variable "ecs_be_cpu" {
  description = "Backend service CPU units"
  type        = number
  default     = 512
}

variable "ecs_be_memory" {
  description = "Backend service memory (MB)"
  type        = number
  default     = 1024
}

variable "ecs_fe_cpu" {
  description = "Frontend service CPU units"
  type        = number
  default     = 256
}

variable "ecs_fe_memory" {
  description = "Frontend service memory (MB)"
  type        = number
  default     = 512
}

variable "ecs_ai_cpu" {
  description = "AI service CPU units"
  type        = number
  default     = 1024
}

variable "ecs_ai_memory" {
  description = "AI service memory (MB)"
  type        = number
  default     = 2048
}

# ==================== ElastiCache ====================
variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.small"
}

# ==================== Container Images ====================
variable "be_image" {
  description = "Backend container image"
  type        = string
}

variable "fe_image" {
  description = "Frontend container image"
  type        = string
}

variable "ai_image" {
  description = "AI service container image"
  type        = string
}

# ==================== Domain ====================
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}
