output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "uploads_public_url" {
  value = "https://${aws_s3_bucket.uploads.bucket}.s3.${var.aws_region}.amazonaws.com/uploads/"
}

output "public_ip" {
  value = aws_eip.web.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_eip.web.public_ip}"
}
