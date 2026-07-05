# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "subnet_newbits" {
  description = "Number of bits to add for subnetting"
  type        = number
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# EKS Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

# ArgoCD Variables
variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD on the EKS cluster"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "7.3.11"
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server (ClusterIP, NodePort)"
  type        = string
  default     = "ClusterIP"
}

# ECR Variables
variable "ecr_repository_names" {
  description = "List of ECR repository names to create for the static web app"
  type        = list(string)
  default     = ["web-app"]
}

# GitHub Actions OIDC Variables
variable "github_oidc_role_name" {
  description = "Name of the IAM role GitHub Actions assumes via OIDC (matches .github/workflows/*.yaml role-to-assume)"
  type        = string
  default     = "github-actions-oidc-role"
}

variable "github_org" {
  description = "GitHub owner/org of the repo"
  type        = string
  default     = "shash2121"
}

variable "github_repo" {
  description = "GitHub repo name"
  type        = string
  default     = "gh-actions-argocd"
}