## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.london | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app | Name of your app. | `string` | n/a | yes |
| artifact\_dir | Path to your static website | `string` | n/a | yes |
| cert\_arn | ARN of the SSL Certificate to use for the Cloudfront Distribution | `string` | `""` | no |
| cname | Name of CNAME record. | `any` | n/a | yes |
| domain | Your root domain, e.g: example.dev. | `any` | n/a | yes |
| enable\_versioning | Enable versioning for your S3 bucket to store artifact. | `bool` | `false` | no |
| error\_page | Error page path for your site, e.g: index.html. | `string` | `"index.html"` | no |
| index\_page | Index page path for your site, e.g: index.html. | `string` | `"index.html"` | no |
| region | AWS region to hosting your resources. | `string` | `"eu-west-2"` | no |
| stage | Stage where app should be deployed like dev, staging or prod. | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket | n/a |
| website\_url | n/a |

