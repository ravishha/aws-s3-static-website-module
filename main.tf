provider "aws" {
  region = var.region
}

provider "aws" {
  alias = "london"
  region = "eu-west-2"
}

resource "aws_s3_bucket" "site_bucket"  {
  bucket = "${var.app}-site-bucket-${var.stage}"
  acl    = "public-read"

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.app}-site-bucket-${var.stage}/*"
    }
  ]
}
EOF

  tags = {
    APP = var.app
    STAGE = var.stage
  }

  versioning {
    enabled = var.enable_versioning
  }

  website {
    index_document = var.index_page
    error_document = var.error_page
  }
}

# Sync artifact to s3 bucket
resource "null_resource" "upload_web_resouce" {
  provisioner  "local-exec" {
    command = "aws s3 sync ${var.artifact_dir} s3://${var.app}-site-bucket--stage-${var.stage}"
  }

  depends_on = [aws_s3_bucket.site_bucket]
}

# Create new ACM if no cert_arn is provided
resource "aws_acm_certificate" "certificate" {
  count = var.cert_arn == "" ? 1 : 0
  provider = aws.london # Certificate which is associated with Cloudfront must be created in eu-west-2

  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = [var.domain]
  
  tags = { 
		Name = var.domain
	}
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = var.cname

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.cname
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.cname}.${var.domain}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cert_arn == "" ? aws_acm_certificate.certificate[0].arn : var.cert_arn
    ssl_support_method  = "sni-only"
  }

  depends_on= [null_resource.upload_web_resouce]
}

resource "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.cname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
