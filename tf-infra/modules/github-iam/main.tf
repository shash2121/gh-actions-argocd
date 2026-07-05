# GitHub Actions OIDC provider + IAM role.
# The role is assumed by GitHub Actions via OIDC (no long-lived keys) to push
# Docker images to the app ECR repo. The ARN is wired into
# .github/workflows/build-push-app.yaml `role-to-assume` field.

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b35339baa177e1bd28"]

  tags = merge(var.tags, {
    Name = "github-actions-oidc"
  })
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.oidc_subject_list
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "ecr_push" {
  name = "${var.role_name}-ecr-push"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = var.ecr_repository_arns
      },
      {
        Sid      = "EcrCreateRepo"
        Effect   = "Allow"
        Action   = ["ecr:CreateRepository"]
        Resource = "*"
      }
    ]
  })
}