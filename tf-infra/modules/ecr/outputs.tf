output "repository_arns" {
  description = "Map of repository name to ARN"
  value       = { for k, r in aws_ecr_repository.this : k => r.arn }
}

output "repository_urls" {
  description = "Map of repository name to URL"
  value       = { for k, r in aws_ecr_repository.this : k => r.repository_url }
}

output "repository_names" {
  description = "List of created repository names"
  value       = [for r in aws_ecr_repository.this : r.name]
}