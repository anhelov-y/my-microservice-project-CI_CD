output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Адреса API сервера кластера"
}

output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "Назва створеного кластера"
}

output "node_group_status" {
  value       = aws_eks_node_group.main.status
  description = "Статус робочих вузлів"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Дані сертифіката кластера"
}
