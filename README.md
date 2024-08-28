# terraform-aws-apigateway

AWS API Gateway Terraform Module

## Usage

### Terraform

terraform/main.tf

```hcl
module "api" {
  source = "git@github.com:aux4/terraform-aws-apigateway.git?ref=main"

  env = var.env

  api_name        = "api-name"
  api_prefix      = "api-prefix-for-lambdas"
  api_description = "API Description"
  api_domain      = "yourdomain.com"

  route53_zone_id = data.aws_route53_zone.aux4_io.zone_id

  api_authorizers = {
    your_authorizer = {
      lambda = {
        file = "Authorizer"
        environment_variables = {
          USER_EXAMPLE_TABLE_NAME  = data.aws_dynamodb_table.user_example.name
        }
        policies = [
          data.aws_iam_policy.lambda_logging_policy.arn,
          data.aws_iam_policy.table_user_example_get_policy.arn
        ]
      }
    }
  }

  api_paths = {
    "/my-api-path/{id}" = {
      get = {
        lambda = {
          file = "HelloWorld"
          environment_variables = {
            EXAMPLE_TABLE_NAME = data.aws_dynamodb_table.example.name
          }
          policies = [
            data.aws_iam_policy.lambda_logging_policy.arn,
            data.aws_iam_policy.table_example_get_policy.arn
          ]
        }
      },
      put = {
        security = [
          "your_authorizer"
        ]
        lambda = {
          file = "SaveWorld"
          environment_variables = {
            EXAMPLE_TABLE_NAME = data.aws_dynamodb_table.example.name
          }
          policies = [
            data.aws_iam_policy.lambda_logging_policy.arn,
            data.aws_iam_policy.table_example_put_policy.arn
          ]
        }
      }
    }
  }
}
```

### Code

src/function/HelloWorld.js

```js
export async function handler(event) {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello World!"
    }),
  };
}
```

src/function/SaveWorld.js

```js
export async function handler(event) {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Save World!"
    }),
  };
}
```

### Build

```bash
mkdir -p dist
zip -r dist/api.zip src node_modules package.json package-lock.json
```
