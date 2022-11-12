import boto3
from boto3.dynamodb.conditions import Key

# Simple query function designed to fetch web contents
def query():
    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('web-app-table')

    resp = table.query(
        KeyConditionExpression=Key('app').eq('hello-world')
    )

    if 'Items' in resp:
        return(resp['Items'][0]['message'])
