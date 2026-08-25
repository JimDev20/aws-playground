#!/bin/bash
set -e

if [ $# -ne 4 ]; then
  echo "Usage: ./process-order.sh ORDER_ID CUSTOMER ITEM AMOUNT"
  exit 1
fi

ORDER_ID="$1"
CUSTOMER="$2"
ITEM="$3"
AMOUNT="$4"

TMP="/tmp/order-${ORDER_ID}.json"
cat > "$TMP" << EOF
{
  "orderId": "${ORDER_ID}",
  "customer": "${CUSTOMER}",
  "item": "${ITEM}",
  "amount": ${AMOUNT},
  "status": "RECEIVED"
}
EOF

aws s3 cp "$TMP" "s3://shopfast-orders-in/orders/${ORDER_ID}.json"
rm "$TMP"

aws dynamodb put-item \
  --table-name Orders \
  --item "{\"orderId\": {\"S\": \"${ORDER_ID}\"}, \"customer\": {\"S\": \"${CUSTOMER}\"}, \"item\": {\"S\": \"${ITEM}\"}, \"amount\": {\"N\": \"${AMOUNT}\"}, \"status\": {\"S\": \"RECEIVED\"}}" \
  --no-cli-pager

aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:shopfast-order-alerts \
  --message "New order ${ORDER_ID} received" \
  --no-cli-pager > /dev/null

aws cloudwatch put-metric-data \
  --namespace ShopFast \
  --metric-name OrdersProcessed \
  --value 1 \
  --no-cli-pager

echo "✅ Order ${ORDER_ID} processed end-to-end."
