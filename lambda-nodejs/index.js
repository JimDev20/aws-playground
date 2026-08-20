exports.handler = async (event, context) => {
    const queryParams = event.queryStringParameters || {};
    const name = queryParams.name || 'World';
    
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            message: `Hello, ${name}!`,
            input: event,
            runtime: 'nodejs18.x'
        })
    };
};
