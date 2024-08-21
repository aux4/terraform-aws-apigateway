terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  api_name = "${var.env}-${var.api_name}"
}

module "lambda_auhtorizer" {
  source = "./modules/lambda"

  for_each = var.api_authorizers

  env                            = var.env
  function_file                  = each.value.lambda.file
  function_zip                   = each.value.lambda.zip
  function_prefix                = local.api_name
  function_runtime               = each.value.lambda.runtime
  function_memory_size           = each.value.lambda.memory_size
  function_timeout               = each.value.lambda.timeout
  function_environment_variables = each.value.lambda.environment_variables
  function_policies              = each.value.lambda.policies
  function_log_retention         = each.value.lambda.log_retention
}

module "lambda_path" {
  source = "./modules/lambda"

  for_each = toset(flatten([for path, methods in var.api_paths : [for method, config in methods : {
    path                           = path
    method                         = method
    function_file                  = config.lambda.file
    function_zip                   = config.lambda.zip
    function_runtime               = config.lambda.runtime
    function_memory_size           = config.lambda.memory_size
    function_timeout               = config.lambda.timeout
    function_environment_variables = config.lambda.environment_variables
    function_policies              = config.lambda.policies
    function_log_retention         = config.lambda.log_retention
  }]]))

  env                            = var.env
  function_file                  = each.value.function_file
  function_zip                   = each.value.function_zip
  function_prefix                = local.api_name
  function_runtime               = each.value.function_runtime
  function_memory_size           = each.value.function_memory_size
  function_timeout               = each.value.function_timeout
  function_environment_variables = each.value.function_environment_variables
  function_policies              = each.value.function_policies
  function_log_retention         = each.value.function_log_retention
}

resource "aws_lambda_permission" "api_lambda_execution_permission" {
  for_each = toset(flatten([for path, methods in var.api_paths : [for method, config in methods : {
    path   = path
    method = method
  }]]))

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_path[each.value.path].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${upper(each.value.method)}/${each.value.path}"
}

resource "aws_iam_role" "api_role" {
  name = "${var.env}-${var.api_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_invoke_lambda_policy" {
  name        = "${local.api_name}-invoke-lambda-policy"
  description = "Policy for allowing API Gateway to invoke Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_log_policy" {
  name        = "${local.api_name}-log-policy"
  description = "Policy for allowing API Gateway to write logs to CloudWatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_log_policy_attachment" {
  policy_arn = aws_iam_policy.api_log_policy.arn
  role       = aws_iam_role.api_role.name
}

resource "aws_iam_role_policy_attachment" "api_invoke_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.api_invoke_lambda_policy.arn
  role       = aws_iam_role.api_role.name
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "/aws/api-gateway/${local.api_name}"
  retention_in_days = var.api_log_retention
}

resource "aws_api_gateway_rest_api" "api" {
  name                         = local.api_name
  description                  = var.api_description
  disable_execute_api_endpoint = true
  binary_media_types           = var.api_binary_media_types

  body = jsonencode({
    swagger = "2.0",
    info = {
      title   = local.api_name
      version = "1.0"
    },
    securityDefinitions = {
      for auth in var.api_authorizers : auth.key => {
        type                         = "apiKey"
        name                         = "Authorization"
        in                           = "header"
        x-amazon-apigateway-authtype = "custom"
        x-amazon-apigateway-authorizer = {
          type                         = "request"
          identitySource               = "method.request.header.Authorization"
          identityValidationExpression = "Bearer [^\\s]+"
          authorizerCredentials        = aws_iam_role.api_role.arn
          authorizerUri                = module.lambda_authorizer[auth.key].invoke_arn
          authorizerResultTtlInSeconds = auth.value.authorizer_result_ttl_in_seconds
        }
      }
    },
    paths = {
      for path, methods in var.api_paths : path =>
      merge(
        {
          for method, config in methods : method => {
            responses = {
              "200" = {
                description = "200 response"
              }
            }
            x-amazon-apigateway-integration = {
              httpMethod  = "POST"
              type        = "aws_proxy"
              uri         = module.lambda_path[path].invoke_arn
              credentials = aws_iam_role.api_role.arn
            }
          }
        },
        {
          options = {
            responses = {
              "200" = {
                description = "200 response"
                headers = {
                  "Access-Control-Allow-Origin" = {
                    type = "string"
                  },
                  "Access-Control-Allow-Methods" = {
                    type = "string"
                  },
                  "Access-Control-Allow-Headers" = {
                    type = "string"
                  }
                }
              }
            },
            x-amazon-apigateway-integration = {
              type = "mock"
              requestTemplates = {
                "application/json" = "{\"statusCode\": 200}"
              }
              responses = {
                "default" = {
                  statusCode = "200"
                  responseParameters = {
                    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                    "method.response.header.Access-Control-Allow-Methods" = join(",", distinct(flatten([for method, config in methods : method])))
                    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  }
                }
              }
            }
          }
      })
    }
  })
}

resource "aws_api_gateway_gateway_response" "api_default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_4XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
  }
}

resource "aws_api_gateway_gateway_response" "api_default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "DEFAULT_5XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_rest_api.api]

  rest_api_id = aws_api_gateway_rest_api.api.id

  variables = {
    deployed_at = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  depends_on = [aws_api_gateway_deployment.api]

  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = var.env

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log_group.arn
    format          = "$context.requestId $context.identity.sourceIp $context.identity.userAgent $context.requestTime $context.httpMethod $context.resourcePath $context.status $context.responseLength $context.protocol"
  }

  variables = {
    "log_level" = "INFO"
    deployed_at = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

