variable "cluster_name" {
  type        = string
  description = "Назва EKS кластера"
}

variable "namespace" {
  type        = string
  default     = "jenkins"
  description = "Namespace для встановлення Jenkins"
}

variable "ecr_repository_url" {
  type        = string
  description = "URL ECR репозиторію "
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS регіон"
}