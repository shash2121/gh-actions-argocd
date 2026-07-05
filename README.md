# gh-actions-argocd

A minimal GitOps pipeline that builds a static web app with GitHub Actions,
stores the image in AWS ECR, and continuously deploys it to an Amazon EKS
cluster using **ArgoCD** — all provisioned with Terraform.

This is a slimmed-down variant of the `gitops-pipeline` project. It
deliberately provisions **no** EKS Pod Identity, RDS database, SQS queue or
Secrets Manager resources — just VPC, EKS, ECR, the GitHub Actions OIDC role,
and ArgoCD itself.

## Architecture

```
            git push (main)
                 │
                 ▼
      ┌─────────────────────┐        ┌──────────────┐
      │  GitHub Actions CI   │  OIDC  │  AWS IAM role │
      │  build + push image │ ─────▶ │  (ECR write)  │
      └─────────────────────┘        └──────────────┘
                 │ docker push
                 ▼
            ┌─────────┐
            │  ECR    │  web-app:sha-xxxxxxx
            └─────────┘
                 │ commit values-app.yaml back to repo
                 ▼
      ┌─────────────────────┐        ┌──────────────────────┐
      │  Git repo (source   │ sync   │  ArgoCD (in EKS)     │
      │  of truth)          │ ◀───── │  Helm release sync   │
      └─────────────────────┘        └──────────────────────┘
                                              │ rollout
                                              ▼
                                      ┌──────────────────┐
                                      │ EKS pods (nginx) │
                                      │ + ClusterIP svc  │
                                      └──────────────────┘
```

## Repository layout

```
gh-actions-argocd/
├── app/                       # Static web app (Nexus landing page)
│   ├── index.html             #   modern responsive UI
│   ├── styles.css             #   glassmorphism + gradients + animations
│   ├── script.js              #   counter + form interactions
│   ├── nginx.conf             #   static-file serving config
│   └── Dockerfile            #   nginx:alpine, copy static assets
├── chart/                    # Helm chart rendered + synced by ArgoCD
│   ├── Chart.yaml
│   ├── values.yaml           # default values (placeholder tag)
│   ├── values-app.yaml       # CI updates `image.tag` here on each push
│   └── templates/
│       ├── deployment.yaml
│   └── service.yaml      # type: ClusterIP (access via port-forward)
├── argocd/
│   └── 01-applications.yaml  # ArgoCD Application (syncs chart/)
├── kustomization.yaml        # `kubectl apply -k .` bootstraps ArgoCD app
├── .github/workflows/
│   └── build-push-app.yaml   # OIDC → ECR build/push → bump Helm tag
└── tf-infra/                 # Terraform: VPC, EKS (+ ArgoCD), ECR, GitHub IAM
    ├── main.tf
    ├── variables.tf
    ├── backend.tf
    ├── terraform.tfvars
    ├── destroy.sh
    └── modules/
        ├── vpc/
        ├── eks/
        │   ├── main.tf        # EKS cluster + managed node group
        │   ├── providers.tf    # helm/kubernetes providers bound to EKS
        │   ├── argocd.tf       # Helm release that installs ArgoCD
        │   ├── variables.tf
        │   └── outputs.tf
        ├── ecr/
        └── github-iam/        # OIDC role for GitHub Actions → ECR
```

## What gets provisioned

| Resource | Provisioned by |
|---|---|
| VPC, public/private subnets, IGW, NAT gateway | `tf-infra/modules/vpc` |
| EKS cluster + managed node group | `tf-infra/modules/eks` |
| **ArgoCD** installed on EKS via Helm | `tf-infra/modules/eks/argocd.tf` |
| ECR repository `web-app` | `tf-infra/modules/ecr` |
| GitHub Actions OIDC IAM role | `tf-infra/modules/github-iam` |

ArgoCD's server service is `ClusterIP` only — it provisions **no** load
balancer of its own. Access it with `kubectl -n argocd port-forward
svc/argocd-server 8080:80` then open `http://localhost:8080`.

Likewise, the web-app `Service` is `ClusterIP` — access it with
`kubectl port-forward svc/web-app 8080:80` then open `http://localhost:8080`.
To clean up the previously-provisioned NLB, just delete the old `Service`
(or let ArgoCD reconcile it after re-sync) — see "Remove the NLB" below.

### Intentionally NOT included

- EKS Pod Identity (no pod identity agent, no `aws_eks_pod_identity_association`)
- RDS / PostgreSQL database
- SQS queue
- Secrets Manager + secrets-store CSI driver
- AWS Load Balancer Controller

## Prerequisites

1. An AWS account and credentials configured locally.
2. An S3 bucket for Terraform state (update `tf-infra/backend.tf`).
3. Ensure `argocd_server_service_type`, `github_org`, `github_repo`, the ECR
   registry URL in `chart/values*.yaml`, and the `role-to-assume` ARN in
   `.github/workflows/build-push-app.yaml` match your account.

## Deploy the infrastructure

```bash
cd tf-infra
terraform init
terraform apply
```

Once `terraform apply` completes, ArgoCD is running on the EKS cluster. Get
the ArgoCD admin password and the LoadBalancer hostname:

```bash
aws eks update-kubeconfig --name dev-eks-cluster --region us-east-1
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d ; echo
kubectl -n argocd port-forward svc/argocd-server 8080:80
# then open http://localhost:8080
```

## Bootstrap the GitOps app

```bash
kubectl apply -k .
```

This creates the ArgoCD `Application` that watches the `chart/` directory and
syncs it into the `default` namespace. On every push to `main`, GitHub
Actions rebuilds the image and bumps `image.tag` in `chart/values-app.yaml`,
which ArgoCD auto-syncs to EKS.

## Clean up

```bash
cd tf-infra
./destroy.sh
```

`destroy.sh` runs a two-stage destroy (EKS first, then the rest) so VPC ENIs
clean up before the VPC is removed.

## Notes

- The GitHub Actions workflow assumes OIDC; no long-lived AWS keys are stored
  as repository secrets.
- The web app is a single static page served by `nginx:alpine` — no build
  step is required.