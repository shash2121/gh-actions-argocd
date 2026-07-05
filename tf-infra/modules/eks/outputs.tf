output "cluster_id" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.cluster.arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data of the EKS cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive   = true
}

output "cluster_status" {
  description = "The status of the EKS cluster"
  value       = aws_eks_cluster.cluster.status
}

output "cluster_security_group_id" {
  description = "The cluster security group ID that was created by the cluster"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.node_group.id
}

output "node_group_arn" {
  description = "The ARN of the EKS node group"
  value       = aws_eks_node_group.node_group.arn
}

output "node_group_status" {
  description = "The status of the EKS node group"
  value       = aws_eks_node_group.node_group.status
}

output "node_group_role_arn" {
  description = "The ARN of the IAM role used by the node group"
  value       = aws_iam_role.node_group.arn
}

output "cluster_platform_version" {
  description = "The platform version of the EKS cluster"
  value       = aws_eks_cluster.cluster.platform_version
}

# ArgoCD Output
output "argocd_deployed" {
  description = "Whether ArgoCD was deployed"
  value       = var.deploy_argocd
}

output "argocd_namespace" {
  description = "The namespace where ArgoCD is deployed"
  value       = var.deploy_argocd ? "argocd" : null
}