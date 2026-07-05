output "role_arn" {
  description = "Wire into .github/workflows/build-push-app.yaml `role-to-assume`"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}