output "instance_1_ip_addr" {
  value = aws_instance.instance1.public_ip
}

output "instance_2_ip_addr" {
  value = aws_instance.instance2.public_ip
}

output "db_instance_addr" {
  value = aws_db_instance.aws_db_instance.address
}