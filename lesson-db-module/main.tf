provider "aws" {
  region = "eu-central-1"
}

variable "region" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "lesson-8-9"
}

variable "cluster_name" {
  default = "django-cluster"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = "django-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b"]
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "django-app-repo"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids 
}

module "s3_backend" {
  source = "./modules/s3-backend"
}

module "jenkins" {
  source             = "./modules/jenkins"
  cluster_name       = module.eks.cluster_name
  ecr_repository_url = module.ecr.repository_url
  region             = var.region
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  cluster_name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
