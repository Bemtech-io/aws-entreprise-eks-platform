terraform {
  backend "s3" {
    bucket       = "bemtech-aws-enterprise-eks-platform-terraform-backend"
    key          = "dev/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}
