terraform {
  backend "s3" {
    bucket  = "tf-code-311902596413-ap-south-1-an"
    key     = "gh-actions-argocd/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}