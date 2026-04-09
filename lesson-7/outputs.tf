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
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
  description = "Виконайте цю команду після apply, щоб підключити kubectl"
}