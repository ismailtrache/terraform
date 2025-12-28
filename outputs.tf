output "public_ip" {
  value = aws_eip.web.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_eip.web.public_ip}"
}
