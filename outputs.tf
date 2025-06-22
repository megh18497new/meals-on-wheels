output "website_url" {
  value = "http://${aws_s3_bucket.foodtruck_site.bucket}.s3-website-${var.aws_region}.amazonaws.com"
  description = "S3 static website endpoint"
}
  