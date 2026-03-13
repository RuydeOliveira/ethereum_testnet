# Define the required providers and their versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.35"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }
}

# Configure the provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "staking"
    }
  }
}

provider "cloudinit" {}
