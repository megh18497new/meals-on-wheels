# handler.py
import json
import boto3
import os

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        bucket = os.environ['BUCKET_NAME']
        key = 'menu.json'

        s3 = boto3.client('s3')
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(body),
            ContentType='application/json'
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Menu updated successfully!'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


