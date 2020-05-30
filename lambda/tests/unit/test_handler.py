import boto3
from moto import mock_s3, mock_dynamodb2
from lambdafunc import app


REGION_NAME = "us-east-2"
MY_BUCKET = "lambda-sample-using-terraform-inbound"
TABLE_NAME = "TerraformExample"


@mock_s3
@mock_dynamodb2
def test_lambda():
    #
    # ARRANGE --
    # add some sample files to the inbound files bucket we will be polling
    s3 = boto3.client("s3", region_name=REGION_NAME)
    s3.create_bucket(Bucket=MY_BUCKET)
    s3.put_object(Bucket=MY_BUCKET, Key="some_file_name_1.txt", Body="")
    s3.put_object(Bucket=MY_BUCKET, Key="some_file_name_2.txt", Body="")

    db = boto3.resource("dynamodb", REGION_NAME)

    db_table = db.create_table(
        TableName=TABLE_NAME,
        KeySchema=[{"AttributeName": "FileId", "KeyType": "HASH"}],
        AttributeDefinitions=[{"AttributeName": "FileId", "AttributeType": "S"}],
        ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5},
    )

    #
    # ACT --
    # call our lambda
    app.lambda_handler(None, "")

    #
    # ASSERT --
    # that the items appear in the dynamodb table as expected

    assert db_table.scan()["Count"] == 2
