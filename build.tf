#
# provider

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


#
# lambda definition

resource "aws_lambda_function" "lambda-function" {
  function_name = "lambda-for-terraform"

  s3_bucket = var.aws_bucket_for_lambda
  s3_key = "function.zip"

  handler = "app.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_exec_role.arn
}


#
# IAM 
#

#
# roles

resource "aws_iam_role" "lambda_exec_role" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
} 
EOF
}


#
# policies

resource "aws_iam_policy" "s3-inbound-bucket-policy" {
  name = "s3_inbound_bucket_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": "arn:aws:s3:::*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "inbound-bucket-policy-attach" {
  role = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.s3-inbound-bucket-policy.arn
}


#
# s3 defintion for the lambda to look for files to save to dynamodb

resource "aws_s3_bucket" "inbound-bucket" {
  bucket = var.aws_bucket_for_files
  force_destroy = true
  acl = "private"

  tags = {
    Name = "Test bucket for terraform lambda processing"
    Environment = var.environment
  }
}


#
# dynamodb definition

resource "aws_dynamodb_table" "dynamodb-table" {
  name = "TerraformExample"
  read_capacity = 5
  write_capacity = 5
  hash_key = "FileId"

  attribute {
    name = "FileId"
    type = "S"
  }

  attribute {
    name = "FileName"
    type = "S"
  }

  global_secondary_index {
    name = "FileNameIndex"
    hash_key = "FileName"
    write_capacity = 5
    read_capacity = 5
    projection_type = "INCLUDE"
    non_key_attributes = [
      "FileId"]
  }

  tags = {
    Name = "dynamodb-files-example"
    Environment = var.environment
  }
}


#
# policies for dynamodb

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
  name = "dynamodb_lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.dynamodb-table.arn}"
    }
  ]
}
EOF
}


#
# API gateway
#

resource "aws_lambda_permission" "api-gateway-invoke-get-lambda" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function.arn
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  #source_arn = "${aws_api_gateway_deployment.api-gateway-deployment.execution_arn}/*/*"
  source_arn = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name = "TerraformSampleAPI"
  description = "API to access application"
  body = data.template_file.api_swagger.rendered
}

data "template_file" "api_swagger" {
  template = file("swagger.yaml")

  vars = {
    get_lambda_arn = "${aws_lambda_function.lambda-function.invoke_arn}"
  }
}

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  stage_name = "default"
}

output "url" {
  value = "${aws_api_gateway_deployment.api-gateway-deployment.invoke_url}/api"
}
