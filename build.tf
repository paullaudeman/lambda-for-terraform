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
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.s3-inbound-bucket-policy.arn
}


#
# s3 defintion for the lambda to look for files to save to dynamodb

resource "aws_s3_bucket" "b" {
  bucket = var.aws_bucket_for_files
  acl = "private"

  tags = {
    Name = "Test bucket for terraform lambda processing"
    Environment = "Dev"
  }
}


#
# dynamodb definitionn


