include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}//src/modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = ""
    private_subnets = [""]
    intra_subnets   = [""]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
    }
EOF
}

# iam_role = "arn:aws:iam::${local.account_vars.locals.account_number}:role/devops-iac"

remote_state {
  backend = "s3"

  config = {
    bucket         = "${get_aws_account_id()}-terraform-remote-state"
    dynamodb_table = "DynamoDBTerraformStateLockTable"
    encrypt        = true
    region         = local.region
    key            = "eks.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

locals {
  region = "us-east-1"
}

inputs = {
  cluster_name             = "my-cluster"
  cluster_version          = 1.32
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets
  cluster_kms_key          = "my-cluster"
  # kms_key_owners = []
  linux_node_group_name            = "linux"
  linux_node_group_ami_type        = "AL2_x86_64"
  linux_node_group_min_size        = 3
  linux_node_group_max_size        = 15
  linux_node_group_instance_type   = ["t3.medium"]
  linux_node_group_capacity_type   = "SPOT"
  linux_nodes_disk_size            = 20
  windows_node_group_name          = "windows"
  windows_node_group_ami_type      = "WINDOWS_CORE_2019_x86_64"
  windows_node_group_min_size      = 3
  windows_node_group_max_size      = 10
  windows_node_group_instance_type = ["t3.medium"]
  windows_node_group_capacity_type = "SPOT"
  windows_nodes_disk_size          = 50
  auth_role_arn                    = ""
  username                         = ""
  region                           = local.region

}

/* vpc_id                   = "vpc-0eb2d467a125f14f3"
subnet_ids               = ["subnet-04cb1083a69a6a3eb", "subnet-03c73e1026406d9a8", "subnet-0f1fb46d719c37a6c"]
control_plane_subnet_ids = ["subnet-04cb1083a69a6a3eb", "subnet-03c73e1026406d9a8", "subnet-0f1fb46d719c37a6c"] */
