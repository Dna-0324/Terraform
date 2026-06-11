# envs/dev/providers.tf
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "noura-formation"
      Module      = "tp04-multi-env"
      ManagedBy   = "Terraform"
      Environment = "staging"
      Owner       = "etudiant07"
    }
  }
}
