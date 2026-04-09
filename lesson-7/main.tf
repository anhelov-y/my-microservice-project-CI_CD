provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name           = "django-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "django-app-repo"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = "django-cluster"
  vpc_id       = module.vpc.vpc_id
  # Використовуємо приватні підмережі з виводу модуля VPC
  subnet_ids   = module.vpc.private_subnet_ids 
}

module "s3_backend" {
  source = "./modules/s3-backend"
}