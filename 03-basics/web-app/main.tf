terraform {
    backend "s3" {
        bucket = "terraform-demo-tf-state"
        key    = "03-basics/web-app/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-state-locking"
        encrypt = true
    }  
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

# AWS S3 Bucket Configuration
resource "aws_s3_bucket" "terraform_bucket" {
  bucket_prefix = "terraform-demo-webapp-data"
  force_destroy = true
}

# AWS S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.terraform_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

# AWS S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt_config" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# AWS EC2 instances
resource "aws_instance" "instance1" {
    ami = "ami-04f215f0e52ec06cf"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!bin/bash
            echo "Hello World 1" > index.html
            python3 -m html.server 8080 &
            EOF
}

resource "aws_instance" "instance2"{
    ami = ""
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!bin/bash
            echo "Hello World" > index.html
            python3 -m html.server 8080 &
            EOF
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

# AWS Security Groups
resource "aws_security_group" "instances" {
    name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "load_balancer" {
  name                  = "web-app-lb"
  load_balancer_type    = "application"
  subnets               = data.aws_subnet_ids.default_subnet.ids
  security_groups       = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_target_group" "instances" {
  name = "example-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id = aws_instance.instance1.id
  port = 8080
}

resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id = aws_instance.instance2.id
  port = 8080
}

resource "aws_alb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.instances.arn
  } 
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port     = 80
  to_port       = 80
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_http_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
}

resource "aws_route53_zone" "primary" {
  name = "devopsdeployed.com"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name = "devdeployed.com"
  type = "A"

  alias {
    name            = aws_lb.load_balancer.dns_name
    zone_id         = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = 20

  auto_minor_version_upgrade = true
  storage_type               = "standard"
  engine                     = "postgres"
  engine_version = "12"
  instance_class = "db.t2.micro"
  name = "mydb"
  password = "foobar123"
  skip_final_snapshot = true
}