include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//src/modules/vpc"
}

locals {
  region = "us-east-1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
      default_tags {
        tags = {
          Environment = "Test"
          Owner       = "TFProviders"
          Project     = "Test"
        }
      }
    }
EOF
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "${get_aws_account_id()}-terraform-remote-state"
    dynamodb_table = "DynamoDBTerraformStateLockTable"
    encrypt        = true
    region         = local.region
    key            = "vpc.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  # Common Configs
  region = local.region

  # VPC Configs
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "My-EKS-VPC"
}
