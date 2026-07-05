# VPC Variables
vpc_cidr         = "10.0.0.0/16"
environment_name = "dev"
subnet_newbits   = 8
region           = "us-east-1"

# EKS Variables
cluster_name              = "dev-eks-cluster"
cluster_version           = "1.36"
node_group_name           = "dev-node-group"
node_group_instance_types = ["m7i-flex.large"]
node_group_desired_size   = 2
node_group_min_size       = 1
node_group_max_size       = 3

# ArgoCD Variables
deploy_argocd              = true
argocd_chart_version       = "7.3.11"
argocd_server_service_type = "LoadBalancer"

# ECR Variables - repo pushed to by the GitHub Actions workflow
ecr_repository_names = ["web-app"]

# GitHub Actions OIDC Variables
github_oidc_role_name = "github-actions-oidc-role"
github_org            = "shash2121"
github_repo           = "gh-actions-argocd"

# Tags
tags = {
  Terraform = "true"
  Project   = "gh-actions-argocd"
}