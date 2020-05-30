from datetime import datetime
import json
import boto3
import uuid


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

    print("=== Starting Lambda")

    s3 = boto3.resource("s3")
    inbound_bucket = s3.Bucket("lambda-sample-using-terraform-inbound")

    db = boto3.resource("dynamodb")
    table = db.Table("TerraformExample")

    files_processed_count = 0

    for file_to_process in inbound_bucket.objects.all():
        print(f"Putting file with name '{file_to_process.key}'")

        table.put_item(
            Item={
                "FileId": str(uuid.uuid1()),
                "FileName": file_to_process.key,
                "DateAdded": str(datetime.utcnow()),
            }
        )

        files_processed_count += 1

    print(f"File(s) processed: {files_processed_count}")
    print("=== Lambda complete.")

    return {"statusCode": 200}
