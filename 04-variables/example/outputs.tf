output "instance_ip_addr" {
  value = aws_instance.example.private_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}