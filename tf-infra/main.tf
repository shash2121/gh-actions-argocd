terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  environment_name = var.environment_name
  aws_region       = var.region
  tags             = var.tags
  subnet_newbits   = var.subnet_newbits
  cluster_name     = var.cluster_name
}

# EKS Module - cluster, node group, and ArgoCD.
# NOTE: This stack intentionally provisions no EKS Pod Identity, RDS, SQS or
# Secrets Manager resources. ArgoCD is installed by Terraform via the Helm
# provider and exposed through a LoadBalancer service (NLB) provisioned by the
# in-tree AWS cloud provider.
module "eks" {
  source                    = "./modules/eks"
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  node_group_name           = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  tags                      = var.tags
  aws_region                = var.region

  # ArgoCD
  deploy_argocd              = var.deploy_argocd
  argocd_chart_version       = var.argocd_chart_version
  argocd_server_service_type = var.argocd_server_service_type
}

# ECR Module - repository for the static web app (built + pushed by GitHub Actions)
module "ecr" {
  source           = "./modules/ecr"
  repository_names = var.ecr_repository_names
  tags             = var.tags
}

# GitHub IAM Module - OIDC role assumed by GitHub Actions to push to ECR
module "github_iam" {
  source              = "./modules/github-iam"
  role_name           = var.github_oidc_role_name
  github_org          = var.github_org
  github_repo         = var.github_repo
  oidc_subject_list   = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"]
  ecr_repository_arns = [for name in var.ecr_repository_names : "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${name}/*"]
  tags                = var.tags
}

data "aws_caller_identity" "current" {}