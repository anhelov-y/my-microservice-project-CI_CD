output "db_host" {
  description = "Endpoint для підключення додатку"
  value       = var.use_aurora ? (length(aws_rds_cluster.this) > 0 ? aws_rds_cluster.this[0].endpoint : null) : (length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].address : null)
}

output "db_port" {
  value = var.db_port
}

output "db_name" {
  value = var.db_name
}
