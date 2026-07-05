#!/usr/bin/env bash
# Two-stage destroy for EKS + VPC.
# Stage 1: destroy EKS cluster, node group, helm releases, everything it owns.
# Stage 2: after ENIs are cleaned up, destroy the VPC + remaining infra.
# Run from tf-infra/ directory.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Stage 1: destroying EKS module ==="
terraform -chdir="$DIR" destroy -target='module.eks' -auto-approve

echo ""
echo "=== Waiting for ENI cleanup (30s) ==="
sleep 30

echo ""
echo "=== Stage 2: destroying everything else (VPC included last) ==="
terraform -chdir="$DIR" destroy -auto-approve

echo ""
echo "Destroy complete."