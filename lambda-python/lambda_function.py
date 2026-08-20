import json

def handler(event, context):
    query_params = event.get('queryStringParameters') or {}
    name = query_params.get('name', 'World')
    
    body = {}
    if event.get('body'):
        body = json.loads(event['body'])
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': f'Hello, {name}!',
            'input': event,
            'runtime': 'python3.9'
        })
    }
