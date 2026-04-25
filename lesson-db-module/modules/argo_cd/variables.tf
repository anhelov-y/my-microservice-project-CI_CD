variable "namespace" {
  type    = string
  default = "argocd"
}

variable "cluster_name" {
  type        = string
  description = "Ім'я EKS кластера для підключення Argo CD"
}

variable "chart_version" {
  type        = string
  default     = "7.7.0"
  description = "Версія Helm чарту для Argo CD"
}
