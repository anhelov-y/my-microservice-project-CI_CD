output "grafana_url" {
  description = "Команда для доступу до Grafana через port-forward"
  value       = "kubectl port-forward svc/prometheus-grafana 3000:80 -n ${var.namespace}"
}

output "prometheus_url" {
  description = "Команда для доступу до Prometheus через port-forward"
  value       = "kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n ${var.namespace}"
}

output "grafana_admin_password" {
  description = "Пароль адміністратора Grafana"
  value       = var.grafana_admin_password
  sensitive   = true
}
