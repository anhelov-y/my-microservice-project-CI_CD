variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Namespace для встановлення Prometheus та Grafana"
}

variable "cluster_name" {
  type        = string
  description = "Ім'я EKS кластера"
}

variable "chart_version" {
  type        = string
  default     = "61.3.2"
  description = "Версія Helm чарту kube-prometheus-stack"
}

variable "grafana_admin_password" {
  type        = string
  default     = "admin123"
  sensitive   = true
  description = "Пароль адміністратора Grafana"
}
