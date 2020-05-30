# Hello there!

Thank you for taking the time to review my coding sample. This project demonstrates the usage of Terraform to provision AWS services in an on-demand fashion (ala. “infrastructure as code”).

The goal of this project was to perform the following actions:

1. Create an AWS Lambda function written in Python 🐍 that will return a list of objects from an S3 bucket.

2. For the Coding part, create a repo on your GitHub/CodeCommit account and include a link to the repo with your answers.

## Requirements

* Store results of the contents of the S3 bucket into a DynamoDB

  For example `{ “files”: [{ “name”: “file1”}, {“name”: “file2”},…]}`

* Infrastructure as code in Terraform to create the lambda, correct permissions, and everything for this to run stand-alone in a new AWS environment.

## Challenges

TDD with passing tests.

# How to run

### Deploy the lambda to a s3 bucket

Before running terraform, you'll need to zip up the lambda and deploy the zip file to a S3 bucket.

Example --

1. Create a bucket for the zipped lambda (e.g. "lambda-sample-using-terraform"):

   `aws s3api create-bucket --bucket=lambda-sample-using-terraform --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2`

2. Zip the lambda:

   `zip function.zip app.py`

3. Upload the zipped lambda to the bucket:

   `aws s3 cp function.zip s3://lambda-sample-using-terraform`

### Run terraform

Ensure that you have Terraform installed and availabe in your PATH. Next, create a `.env` file and source it with the following variables (or pass them in when you call your terraform:

```bash
export TF_VAR_aws_region="us-east-2"
export TF_VAR_environment="dev"
export TF_VAR_aws_access_key="<your-access-key>"
export TF_VAR_aws_secret_key="<your-secret-key"
export TF_VAR_aws_bucket_for_lambda="lambda-sample-using-terraform"
export TF_VAR_aws_bucket_for_files="lambda-sample-using-terraform-inbound"
```

And then source with `. ./.env`

Next, run terraform!

1. Navigate to the folder containing the `build.tf` (the main build script)

2. Run `terraform init`

   ​	This will ensure any required dependencies are installed.

3. Run `terraform plan`

4. Run `terraform build`

5. Note the output from the terraform build, and the URL it gives you to run the lambda. 

6. Upload some sample files to the inbound folder (see TF_VAR_aws_bucket_for_files).

   e.g. 

   ```bash
   $ touch test1.txt test2.txt test3.txt test4.txt
   ```

   then upload these sample files to the inbound bucket:

   ```bash
   $ aws s3 sync ~/temp s3://lambda-sample-using-terraform-inbound --exclude "*" --include "test*"
   ```

7. Using the lambda url you noted from Step 5, access this url in your browser (or use curl or httpie from the terminal) to hit the url.

8. View results in your AWS console for your dynamo db.

9. When you're done reviewing the results, be sure to clean up your resources with `terraform destroy`

### Running unit tests

Run the following from your terminal:

```bash
$ python3 -m pytest
```

# Discussion and thanks!

This coding exercise was fun and through it I had the opportunity to gain direct experience using Terraform to provision AWS resources through markup in an on-demand fashion. 

Opportunities for additional improvement:

* In this sample, each time the Lambda is executed it will process the complete list of files currently in the S3 bucket and insert those into the table. 

  In a further developed solution, we would probably want to move processed files into another folder so we would not process the same files again.

  Or, we could check each file we find in the bucket to see if it already exists in the table, but that would have an undesirable runtime impact.

* Explore the possibility of versioning the lambda for future updates. One strategy could be to introduce a version environment variable that the build could use to look for the respective version of the lambda zip, and then deploy that.

* Logging to Cloudwatch could be implemented with additional resource provisioning. 

This coding endeavor was really great as it gave me the opportunity to learn about Terraform and to see its value in action. I appreciated seeing how to orchestrate multiple cloud services in an on-demand fashion and can certainly see the value in this declarative approach to cloud resource provisoning.

