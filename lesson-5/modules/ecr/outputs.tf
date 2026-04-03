output "repository_url" {
  description = "URL створеного ECR репозиторію"
  value       = aws_ecr_repository.main.repository_url
}