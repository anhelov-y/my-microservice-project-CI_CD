output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.ecr_repository_url
}

output "s3_bucket_name" {
  description = "The Name of the S3 bucket used for the Terraform backend"
  value       = module.s3_backend.s3_bucket_name
}