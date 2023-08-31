variable "instance_name" {
  description = "instance name"
  type = string
}

variable "ami" {
  description = "instance ami type"
  type = string
}

variable "instance_type" {
  description = "instance type"
  type = string
  default = "t2.micro"
}

variable "db_user" {
  description = "database username"
  type = string
  default = "foo"
}

variable "db_pass" {
  description = "database password"
  type = string
  sensitive = true
}