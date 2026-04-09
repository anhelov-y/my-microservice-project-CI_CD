variable "cluster_name" {
  type        = string
  description = "Назва EKS кластера"
}

variable "vpc_id" {
  type        = string
  description = "ID вашої VPC (отримаємо з outputs модуля vpc)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Список приватних підмереж для робочих вузлів"
}