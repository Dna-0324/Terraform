# envs/dev/backend.tf
terraform {
  backend "s3" {
    bucket       = "tf-state-noura-formation"
    key          = "envs/staging/vpc/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
