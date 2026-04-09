resource "aws_ecr_repository" "django" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

