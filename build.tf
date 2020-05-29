#
# provider

provider "aws" {
  region     = var.aws_region 
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key 
}


#
# lambda defintion

resource "aws_lambda_function" "lambda-function" {
  function_name = "lambda-for-terraform"

  s3_bucket = var.aws_bucket_for_lambda 
  s3_key = "function.zip"

  handler = "app.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_exec.arn
}


#
# IAM policy defintion

resource "aws_iam_role" "lambda_exec" {
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
# s3 defintion


#
# dynamodb definitionn

