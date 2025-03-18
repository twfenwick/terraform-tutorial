# Back in main.tf, we actually need to call the outputs
output "privateip" {
  value = aws_instance.myec2db.private_ip
}