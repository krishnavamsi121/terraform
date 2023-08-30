terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "example"{
    ami = "ami-04f215f0e52ec06cf"
    instance_type = "t2.micro"
}