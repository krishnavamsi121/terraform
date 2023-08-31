terraform {
  backend "s3" {
    bucket         = "terraform-demo-tf-state"
    key            = "07-workspaces/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "db_pass" {
  description = "database password"
  type        = string
  sensitive   = true
}

locals {
  environment_name = terraform.workspace
}

module "web-app" {
  source = "../../06-modules/web-app-module"

  bucket_prefix    = "web-app-data-${local.environment_name}"
  domain           = "devopsdeployed.com"
  environment_name = local.environment_name
  create_dns_zone  = terraform.workspace == "production" ? true : false
  instance_type    = "t2.micro"
  db_name          = "${local.environment_name}mydb"
  db_user          = "foo"
  db_pass          = var.db_pass
}