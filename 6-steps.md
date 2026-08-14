@JimDev20 ➜ /workspaces/aws-playground (main) $ floci start --persist .floci-data
Removing stopped container 'floci'...
Checking image floci/floci:latest (policy: missing)...
Starting Floci AWS container...
Container started (c4587c81b0d4)
Waiting for Floci AWS to be ready...
Waiting... (19s remaining)   Floci AWS is ready (http://localhost:4566)
@JimDev20 ➜ /workspaces/aws-playground (main) $ eval $(floci env)
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sts get-caller-identity
{
    "UserId": "000000000000",
    "Account": "000000000000",
    "Arn": "arn:aws:iam::000000000000:root"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws cloudwatch put-metric-data --namespace UncleGeorge --metric-name Visits --value 1 --no-cli-pager
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws cloudwatch get-metric-statistics --namespace UncleGeorge --metric-name Visits --start-time 2026-08-14T12:50:57Z --end-time 2026-08-14T13:20:57Z --period 60 --statistics Sum --no-cli-pager
{
    "Label": "Visits",
    "Datapoints": [
        {
            "Timestamp": "2026-08-14T13:20:00+00:00",
            "Sum": 1.0,
            "Unit": "None"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws logs create-log-group --log-group-name /uncle-george/orders --no-cli-pager
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws logs create-log-stream --log-group-name /uncle-george/orders --log-stream-name order-1 --no-cli-pager
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws logs put-log-events --log-group-name /uncle-george/orders --log-stream-name order-1 --log-events timestamp=1786713772918,message="order placed" --no-cli-pager
{
    "nextSequenceToken": "b6ef5b0e-626c-437e-9679-81c963da6b44"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws logs get-log-events --log-group-name /uncle-george/orders --log-stream-name order-1 --no-cli-pager
{
    "events": [
        {
            "timestamp": 1786713772918,
            "message": "order placed",
            "ingestionTime": 1786713802078
        }
    ],
    "nextForwardToken": "f/1",
    "nextBackwardToken": "b/0"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws events put-rule --name order-placed-rule --event-pattern '{"source":["uncle-george"]}' --no-cli-pager
{
    "RuleArn": "arn:aws:events:us-east-1:000000000000:rule/order-placed-rule"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws events put-targets --rule order-placed-rule --targets Id=1,Arn=arn:aws:sns:us-east-1:000000000000:order-alerts --no-cli-pager
{
    "FailedEntryCount": 0,
    "FailedEntries": []
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sns list-topics --no-cli-pager
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:us-east-1:000000000000:order-alerts"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws events list-targets-by-rule --rule order-placed-rule --no-cli-pager
{
    "Targets": [
        {
            "Id": "1",
            "Arn": "arn:aws:sns:us-east-1:000000000000:order-alerts"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws events put-events --entries '[{"Source":"uncle-george","DetailType":"OrderPlaced","Detail":"{\"order\":\"french-baguette\"}"}]' --no-cli-pager
{
    "FailedEntryCount": 0,
    "Entries": [
        {
            "EventId": "ce7bbca4-7359-4ecc-9c4b-60f79e0d1b4c"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs list-queues --no-cli-pager
{
    "QueueUrls": [
        "http://localhost:4566/000000000000/notifications"
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs get-queue-attributes --queue-url http://localhost:4566/000000000000/orders --attribute-names QueueArn --no-cli-pager

aws: [ERROR]: An error occurred (AWS.SimpleQueueService.NonExistentQueue) when calling the GetQueueAttributes operation: The specified queue does not exist.
@JimDev20 ➜ /workspaces/aws-playground (main) $  aws sqs list-queues --no-cli-pager → expect {"QueueUrls": []}

usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help


aws: [ERROR]: Unknown options: expect, {QueueUrls:, []}, →
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs list-queues --no-cli-pager
{
    "QueueUrls": [
        "http://localhost:4566/000000000000/notifications"
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs create-queue --queue-name orders --no-cli-pager
{
    "QueueUrl": "http://localhost:4566/000000000000/orders"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs get-queue-attributes --queue-url http://localhost:4566/000000000000/orders --attribute-names QueueArn --no-cli-pager
{
    "Attributes": {
        "QueueArn": "arn:aws:sqs:us-east-1:000000000000:orders"
    }
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:order-alerts --protocol sqs --notification-endpoint arn:aws:sqs:us-east-1:000000000000:orders --no-cli-pager
{
    "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:order-alerts:bcfa6bab-acf2-482c-9d8f-d8bb5ed68478"
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws events put-events --entries '[{"Source":"uncle-george","DetailType":"OrderPlaced","Detail":"{\"order\":\"french-baguette\"}"}]' --no-cli-pager
{
    "FailedEntryCount": 0,
    "Entries": [
        {
            "EventId": "78cb0952-abc5-464d-867e-a194fd7d4bae"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ aws sqs receive-message --queue-url http://localhost:4566/000000000000/orders --no-cli-pager
{
    "Messages": [
        {
            "MessageId": "bc6a4013-7ac2-46ad-b2fe-b5f81fd1d4e3",
            "ReceiptHandle": "f513cc91-8fe7-423b-bced-98e7e9a648cf",
            "MD5OfBody": "a27106023c264d1c6541f3c216557b60",
            "Body": "{\"Type\":\"Notification\",\"MessageId\":\"14db1f99-0f2e-47ba-b973-6d3a86b9e141\",\"TopicArn\":\"arn:aws:sns:us-east-1:000000000000:order-alerts\",\"Timestamp\":\"2026-08-14T13:33:26.222596797Z\",\"Subject\":\"EventBridge\",\"Message\":\"{\\\"version\\\":\\\"0\\\",\\\"id\\\":\\\"78cb0952-abc5-464d-867e-a194fd7d4bae\\\",\\\"source\\\":\\\"uncle-george\\\",\\\"detail-type\\\":\\\"OrderPlaced\\\",\\\"account\\\":\\\"000000000000\\\",\\\"time\\\":\\\"2026-08-14T13:33:26.222540071Z\\\",\\\"region\\\":\\\"us-east-1\\\",\\\"resources\\\":[],\\\"detail\\\":{\\\"order\\\":\\\"french-baguette\\\"},\\\"event-bus-name\\\":\\\"default\\\"}\",\"MessageAttributes\":{}}"
        }
    ]
}
@JimDev20 ➜ /workspaces/aws-playground (main) $ 