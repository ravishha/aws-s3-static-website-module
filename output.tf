output "cloudfront_endpoint" {
  value =  aws_cloudfront_distribution.distribution.domain_name
}

output "s3_bucket_endpoint" {
  value = aws_s3_bucket.site_bucket.website_endpoint
}


output "s3_bucket" {
  value = aws_s3_bucket.site_bucket.arn
}

output "aws_route53_record" {
  value = aws_route53_record.www.fqdn
}
