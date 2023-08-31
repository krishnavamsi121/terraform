# General variables

variable "region" {
  description = "default instance of provider"
  type = string
  default = "us-east-1"
}

variable "app_name" {
  description = "name of web application"
  type = string
  default = "web-app"
}

variable "environment_name" {
  description = "Deployment environment (dev/staging/production)"
  type = string
  default = "dev"
}

# EC2 variables

variable "ami" {
  description = "EC2 instance AMI"
  type = string
  default = "ami-04f215f0e52ec06cf"
}

variable "instance_type" {
  description = "ec2 instance type"
  type = string
  default = "t2.micro"
}

# S3 variables

variable "bucket_prefix" {
  description = "prefix of s3 bucket for app data"
  type = string
}

# Route 53 variables

variable "create_dns_zone" {
  description = "If true, create new route53 zone, if false read existing route53 zone"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Domain of website"
  type = string
}

# RDS variables

variable "db_name" {
  description = "database name"
  type = string
}

variable "db_user" {
  description = "database username"
  type = string
}

variable "db_pass" {
  description = "database password"
  type = string
  sensitive = true
}