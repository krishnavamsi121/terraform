terraform {
    backend "s3" {
        bucket = "terraform-demo-tf-state"
        key = "06-modules/web-app/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-state-locking"
        encrypt = true
    }

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

variable "db_pass1" {
  description = "database password for web-app-1"
  type = string
  sensitive = true
}

variable "db_pass2" {
  description = "database password for web-app-2"
  type = string
  sensitive = true
}

module "web-app-1" {
  source = "../web-app-module"

  bucket_prefix = "web-app-1-data"
  domain = "devdeployed.com"
  app_name = "web-app-1"
  environment_name = "production"
  instance_type = "t2.micro"
  create_dns_zone = true
  db_name = "mydb"
  db_user = "foo"
  db_pass = var.db_pass1
}

module "web-app-2" {
  source = "../web-app-module"

  bucket_prefix = "web-app-2-data"
  domain = "devdeployed.com"
  app_name = "web-app-2"
  environment_name = "production"
  instance_type = "t2.micro"
  create_dns_zone = true
  db_name = "mydb"
  db_user = "foo"
  db_pass = var.db_pass1
}