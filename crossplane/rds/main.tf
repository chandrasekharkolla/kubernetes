data "aws_rds_engine_version" "test" {
  engine = "aurora-mysql"
}

output "name" {
  value = data.aws_rds_engine_version.test
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
