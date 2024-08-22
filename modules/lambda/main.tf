terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  function_name = replace("${var.env}-${lower(var.function_prefix)}-${lower(var.function_file)}", "--", "-")
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.function_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  for_each = toset(var.function_policies)

  policy_arn = each.value
  role       = aws_iam_role.lambda_role.name
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.function_log_retention
}

resource "aws_lambda_function" "lambda" {
  function_name = local.function_name
  handler       = "src/function/${var.function_file}.handler"
  role          = aws_iam_role.lambda_role.arn

  runtime     = var.function_runtime
  memory_size = var.function_memory_size
  timeout     = var.function_timeout

  source_code_hash = filebase64sha256(var.function_zip)
  filename         = var.function_zip

  logging_config {
    log_format = "JSON"
    log_group = aws_cloudwatch_log_group.lambda_log_group.name
  }

  environment {
    variables = var.function_environment_variables
  }
}
