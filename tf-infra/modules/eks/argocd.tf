# ------------------------------------ ArgoCD ------------------------------------
# Namespace is managed by the Helm chart (createNamespace=true).
# This avoids Terraform namespace finalizer issues on destroy.
#
# ArgoCD is provisioned inside the EKS cluster by Terraform. The server is
# exposed via a LoadBalancer service (NLB provisioned by the in-tree AWS cloud
# provider) so it is reachable without the AWS Load Balancer Controller.

resource "helm_release" "argocd" {
  count = var.deploy_argocd ? 1 : 0

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = var.argocd_server_service_type
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "server.replicas"
    value = "1"
  }

  set {
    name  = "repoServer.replicas"
    value = "1"
  }

  set {
    name  = "applicationSet.replicas"
    value = "1"
  }

  depends_on = [aws_eks_node_group.node_group]
}