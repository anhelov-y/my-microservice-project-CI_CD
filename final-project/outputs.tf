output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "update_config_command" {
  value       = "aws eks update-kubeconfig --region eu-central-1 --name ${module.eks.cluster_name}"
  description = "Виконайте цю команду після apply, щоб підключити kubectl"
}

output "rds_hostname" {
  description = "Адреса підключення до бази даних"
  value       = module.rds.db_host
}

output "rds_port" {
  description = "Порт бази даних"
  value       = module.rds.db_port
}

output "rds_database_name" {
  description = "Назва бази даних"
  value       = module.rds.db_name
}

output "grafana_access" {
  description = "Команда для доступу до Grafana"
  value       = module.monitoring.grafana_url
}

output "prometheus_access" {
  description = "Команда для доступу до Prometheus"
  value       = module.monitoring.prometheus_url
}

output "jenkins_access" {
  description = "Команда для доступу до Jenkins"
  value       = "kubectl port-forward svc/jenkins 8080:8080 -n jenkins"
}

output "argocd_access" {
  description = "Команда для доступу до Argo CD"
  value       = "kubectl port-forward svc/argocd-server 8081:443 -n argocd"
}
