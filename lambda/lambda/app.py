import json
import boto3


def lambda_handler(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """

    s3 = boto3.resource("s3")
    inbound_bucket = s3.Bucket("lambda-sample-using-terraform-inbound")

    files = []

    for file_to_process in inbound_bucket.objects.all():
        files.append({"name": file_to_process})

    return {
        "statusCode": 200,
        "body": json.dumps({
            "files": files
        }),
    }
