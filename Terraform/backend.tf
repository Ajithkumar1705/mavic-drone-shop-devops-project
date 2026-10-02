terraform {
  backend "s3" {
    # Supply environment-specific values during `terraform init`.
    # Example:
    #   terraform init -backend-config=backend.hcl
    key     = "eks/terraform.tfstate"
    encrypt = true
  }
}
