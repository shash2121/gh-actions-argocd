variable "role_name" {
  description = "Name of the IAM role GitHub Actions assumes"
  type        = string
}

variable "github_org" {
  description = "GitHub owner/org"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name"
  type        = string
}

variable "oidc_subject_list" {
  description = "JWT sub claims allowed to assume the role"
  type        = list(string)
}

variable "ecr_repository_arns" {
  description = "ARNs (with /*) the GitHub Actions role can push to"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}