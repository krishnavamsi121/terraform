terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "consul" {
  source = "hashicorp/consul/aws"
  version = "0.1.0"
}