provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create the S3 bucket
resource "aws_s3_bucket" "foodtruck_site" {
  bucket = var.bucket_name

  tags = {
    Name        = "MealsOnWheels"
    Environment = "Dev"
  }
}

# Configure the bucket for website hosting
resource "aws_s3_bucket_website_configuration" "foodtruck_site" {
  bucket = aws_s3_bucket.foodtruck_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.foodtruck_site.id
  key          = "index.html"
  source       = "${path.module}/index.html"  # or your local file path
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

resource "aws_s3_object" "logo_image" {
  bucket       = aws_s3_bucket.foodtruck_site.id
  key          = "images/logo.png"
  source       = "${path.module}/images/logo.png"
  content_type = "image/png"
}


# Allow public access (necessary for website)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.foodtruck_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.foodtruck_site.arn}/*"
    }]
  })
}

# Optional: Remove all public access blocking (default is to block)
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.foodtruck_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject"
      ],
      Resource = "arn:aws:s3:::${aws_s3_bucket.foodtruck_site.bucket}/*"
    }]
  })
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_src/lambda.zip"
}


resource "aws_lambda_function" "update_menu" {
  function_name = "update_menu_lambda"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.foodtruck_site.bucket
    }
  }
}

resource "aws_apigatewayv2_api" "menu_api" {
  name          = "MenuAPI"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_menu.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.menu_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.menu_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.update_menu.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "menu_route" {
  api_id    = aws_apigatewayv2_api.menu_api.id
  route_key = "POST /menu"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.menu_api.id
  name        = "$default"
  auto_deploy = true
}

output "menu_api_endpoint" {
  value = aws_apigatewayv2_api.menu_api.api_endpoint
}


#CloudFront

resource "aws_cloudfront_distribution" "foodtruck_cdn" {
  origin {
    domain_name = aws_s3_bucket.foodtruck_site.bucket_regional_domain_name
    origin_id   = "s3-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "MealsOnWheelsCDN"
    Environment = "Dev"
  }
}

output "cdn_url" {
  value = aws_cloudfront_distribution.foodtruck_cdn.domain_name
}
