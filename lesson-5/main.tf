provider "aws" {
  region = "us-west-2"
}

# 1. Модуль S3 для стейтів
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-terraform-state-testanhelov-2026"
  table_name  = "terraform-locks"
}

# 2. Модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-5-vpc"
}

# 3. Модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}