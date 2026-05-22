terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    aws-parallelcluster = {
      source  = "aws-tf/aws-parallelcluster"
      version = "~> 1.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# The ParallelCluster provider calls the ParallelCluster REST API, which is
# deployed by the separate bootstrap_api/ Terraform root. The provider auto-
# discovers the API endpoint from the stack name.
provider "aws-parallelcluster" {
  region         = var.aws_region
  profile        = var.aws_profile
  api_stack_name = var.pcluster_api_stack_name
}
