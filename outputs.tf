output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "uploads_public_url" {
  value = "https://${aws_s3_bucket.uploads.bucket}.s3.${var.aws_region}.amazonaws.com/uploads/"
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "alb_http_url" {
  value = "http://${aws_lb.web.dns_name}"
}
