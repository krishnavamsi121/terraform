resource "aws_instance" "instance1" {
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!bin/bash
            echo "Hello World 1" > index.html
            python3 -m html.server 8080 &
            EOF
}

resource "aws_instance" "instance2"{
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!bin/bash
            echo "Hello World" > index.html
            python3 -m html.server 8080 &
            EOF
}