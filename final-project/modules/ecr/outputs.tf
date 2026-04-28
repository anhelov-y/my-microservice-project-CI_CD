output "repository_url" {
  value       = aws_ecr_repository.django.repository_url
  description = "URL для тегування та пушу Docker-образу"
}