terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
