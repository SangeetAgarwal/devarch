# Let Claude Build Your AWS Serverless Backend

A practical guide to having Claude Code help you build a production-ready serverless API on AWS — from domain purchase to hardened deployment.

## What You'll Build

By the end of this guide, you'll have:
- A custom domain (e.g., `api.yourdomain.com`)
- SSL/TLS certificate (HTTPS)
- REST API via API Gateway
- Lambda functions for business logic
- DynamoDB for data storage
- Basic hardening (throttling, validation, CORS)

**Not covered here:** Authentication (Cognito, OAuth) — that's a separate guide.

## Prerequisites

- AWS account with admin access
- AWS CLI installed and configured (`aws configure`)
- Node.js 18+ (for Lambda runtime)
- Basic familiarity with terminal/command line

## Part 1: Domain and DNS Setup

### Option A: Buy Domain Through Route 53

The simplest path — everything stays in AWS.

1. Open AWS Console → Route 53 → Registered domains
2. Click "Register domain"
3. Search for your domain, add to cart
4. Complete purchase (~$12-15/year for .com)
5. AWS automatically creates a hosted zone

**Ask Claude:**
> "Help me register a domain in Route 53 and verify the hosted zone was created"

### Option B: External Registrar → Route 53

If you already own a domain (GoDaddy, Namecheap, etc.):

1. **Create hosted zone in Route 53:**
   ```bash
   aws route53 create-hosted-zone --name yourdomain.com --caller-reference $(date +%s)
   ```

2. **Copy the NS records** from the hosted zone (4 nameservers)

3. **Update your registrar** to use Route 53 nameservers
   - Login to GoDaddy/Namecheap
   - Find "Nameservers" or "DNS Management"
   - Replace default nameservers with the 4 AWS ones

4. **Wait for propagation** (can take 24-48 hours)

**Ask Claude:**
> "Help me create a Route 53 hosted zone for mydomain.com and show me the nameservers to configure at my registrar"

### Verify DNS is Working

```bash
dig yourdomain.com NS +short
```

Should return AWS nameservers (ns-xxx.awsdns-xx.xxx).

---

## Part 2: SSL Certificate (ACM)

You need an SSL certificate for HTTPS. AWS Certificate Manager provides free certificates.

**Important:** For API Gateway custom domains, create the certificate in **us-east-1** (N. Virginia) regardless of where your API lives.

```bash
aws acm request-certificate \
  --domain-name api.yourdomain.com \
  --validation-method DNS \
  --region us-east-1
```

### Validate the Certificate

1. Go to ACM console → your certificate → "Create records in Route 53"
2. Click the button — AWS adds the validation DNS record automatically
3. Wait 5-30 minutes for validation (status changes to "Issued")

**Ask Claude:**
> "Help me request an ACM certificate for api.mydomain.com and validate it via DNS"

---

## Part 3: DynamoDB Table

Before building the API, set up your data store.

### Single-Table Design (Recommended)

For most applications, a single DynamoDB table with composite keys works well:

```bash
aws dynamodb create-table \
  --table-name MyAppData \
  --attribute-definitions \
    AttributeName=PK,AttributeType=S \
    AttributeName=SK,AttributeType=S \
  --key-schema \
    AttributeName=PK,KeyType=HASH \
    AttributeName=SK,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

### Access Patterns

Design your keys around how you'll query:

| Entity | PK | SK | Example |
|--------|----|----|---------|
| User | `USER#<id>` | `PROFILE` | `USER#123`, `PROFILE` |
| User's orders | `USER#<id>` | `ORDER#<timestamp>` | `USER#123`, `ORDER#2025-01-15` |
| Order details | `ORDER#<id>` | `DETAILS` | `ORDER#456`, `DETAILS` |

**Ask Claude:**
> "Help me design a DynamoDB single-table schema for a [describe your app] with these access patterns: [list how you'll query data]"

---

## Part 4: Lambda Functions

### Project Structure

```
my-api/
├── src/
│   ├── handlers/
│   │   ├── users.ts        # User CRUD operations
│   │   ├── orders.ts       # Order operations
│   │   └── health.ts       # Health check endpoint
│   ├── lib/
│   │   ├── dynamo.ts       # DynamoDB client
│   │   ├── response.ts     # Standard response helpers
│   │   └── validation.ts   # Input validation
│   └── types/
│       └── index.ts        # TypeScript types
├── package.json
├── tsconfig.json
└── template.yaml           # SAM template (optional)
```

### Basic Handler Pattern

```typescript
// src/handlers/users.ts
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME!;

export async function getUser(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const userId = event.pathParameters?.id;

  if (!userId) {
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Missing user ID' }),
    };
  }

  try {
    const result = await docClient.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { PK: `USER#${userId}`, SK: 'PROFILE' },
    }));

    if (!result.Item) {
      return {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'User not found' }),
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result.Item),
    };
  } catch (error) {
    console.error('Error fetching user:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
}
```

### Response Helper

```typescript
// src/lib/response.ts
export function success(data: unknown) {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*', // Tighten in production
    },
    body: JSON.stringify(data),
  };
}

export function error(statusCode: number, message: string) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({ error: message }),
  };
}
```

**Ask Claude:**
> "Help me create a Lambda handler for [describe your endpoint] that reads/writes to DynamoDB table MyAppData"

### Build and Package

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Create deployment package
cd dist && zip -r ../function.zip . && cd ..
zip -ur function.zip node_modules
```

### Deploy Lambda

```bash
# Create IAM role for Lambda (one-time)
aws iam create-role \
  --role-name MyApiLambdaRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach policies
aws iam attach-role-policy \
  --role-name MyApiLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
  --role-name MyApiLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess

# Create Lambda function
aws lambda create-function \
  --function-name MyApiUsers \
  --runtime nodejs18.x \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/MyApiLambdaRole \
  --handler handlers/users.getUser \
  --zip-file fileb://function.zip \
  --environment Variables={TABLE_NAME=MyAppData}
```

---

## Part 5: API Gateway

### Create REST API

```bash
# Create the API
aws apigateway create-rest-api \
  --name "My API" \
  --description "My serverless API" \
  --endpoint-configuration types=REGIONAL
```

Save the returned `id` — you'll need it.

### Create Resources and Methods

This is verbose via CLI. **Ask Claude to help:**

> "Help me create API Gateway resources and methods for these endpoints:
> - GET /users/{id}
> - POST /users
> - GET /health
>
> Connect them to Lambda function MyApiUsers"

### Deploy the API

```bash
aws apigateway create-deployment \
  --rest-api-id YOUR_API_ID \
  --stage-name prod
```

### Custom Domain Setup

```bash
# Create custom domain
aws apigateway create-domain-name \
  --domain-name api.yourdomain.com \
  --regional-certificate-arn arn:aws:acm:us-east-1:YOUR_ACCOUNT:certificate/YOUR_CERT_ID \
  --endpoint-configuration types=REGIONAL

# Map to your API
aws apigateway create-base-path-mapping \
  --domain-name api.yourdomain.com \
  --rest-api-id YOUR_API_ID \
  --stage prod
```

### DNS Record for Custom Domain

Get the target domain name from the custom domain:

```bash
aws apigateway get-domain-name --domain-name api.yourdomain.com
```

Create Route 53 alias record:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id YOUR_ZONE_ID \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.yourdomain.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "d-xxxxxxxx.execute-api.us-east-1.amazonaws.com",
          "HostedZoneId": "Z1UJRXOUMOOFQ8",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'
```

---

## Part 6: Hardening

### API Gateway Throttling

Prevent abuse with rate limiting:

```bash
aws apigateway update-stage \
  --rest-api-id YOUR_API_ID \
  --stage-name prod \
  --patch-operations \
    op=replace,path=/throttling/rateLimit,value=100 \
    op=replace,path=/throttling/burstLimit,value=200
```

This limits to 100 requests/second sustained, 200 burst.

### Lambda Concurrency Limits

Prevent runaway costs:

```bash
aws lambda put-function-concurrency \
  --function-name MyApiUsers \
  --reserved-concurrent-executions 50
```

### Input Validation

**Always validate input in your Lambda handlers:**

```typescript
// src/lib/validation.ts
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validateRequired(obj: Record<string, unknown>, fields: string[]): string[] {
  const missing: string[] = [];
  for (const field of fields) {
    if (obj[field] === undefined || obj[field] === null || obj[field] === '') {
      missing.push(field);
    }
  }
  return missing;
}

// Usage in handler
const missing = validateRequired(body, ['name', 'email']);
if (missing.length > 0) {
  return error(400, `Missing required fields: ${missing.join(', ')}`);
}
```

### CORS Configuration

For browser clients, configure CORS properly:

```typescript
// Tighten this in production
const ALLOWED_ORIGINS = [
  'https://yourdomain.com',
  'https://www.yourdomain.com',
];

export function corsHeaders(origin: string | undefined) {
  const allowedOrigin = origin && ALLOWED_ORIGINS.includes(origin)
    ? origin
    : ALLOWED_ORIGINS[0];

  return {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Headers': 'Content-Type,Authorization',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
  };
}
```

### API Gateway Request Validation

Add request validators to reject malformed requests before they hit Lambda:

```bash
aws apigateway create-request-validator \
  --rest-api-id YOUR_API_ID \
  --name "Validate body" \
  --validate-request-body \
  --no-validate-request-parameters
```

**Ask Claude:**
> "Help me add request body validation to my API Gateway POST /users endpoint with a JSON schema"

### CloudWatch Alarms

Set up alerts for errors:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "MyApi-5xx-Errors" \
  --metric-name 5XXError \
  --namespace AWS/ApiGateway \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ApiName,Value="My API" \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:YOUR_ACCOUNT:your-alerts-topic
```

---

## Part 7: Deploy Scripts

Reusable scripts make deployments repeatable and less error-prone. Keep these in a `scripts/` folder.

### Project Structure with Scripts

```
my-api/
├── scripts/
│   ├── config.sh              # Shared configuration
│   ├── deploy-dynamodb.sh     # Create/update DynamoDB table
│   ├── deploy-iam.sh          # Create IAM role and policies
│   ├── deploy-lambda.sh       # Build and deploy Lambda
│   ├── deploy-api-gateway.sh  # Create/update API Gateway
│   ├── deploy-custom-domain.sh # Set up custom domain + DNS
│   └── deploy-all.sh          # Run all scripts in order
├── src/
│   └── ...
└── package.json
```

### Configuration File

```bash
#!/bin/bash
# scripts/config.sh - Shared configuration for all deploy scripts

# Project settings
export PROJECT_NAME="myapi"
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Resource names (derived from project name)
export TABLE_NAME="${PROJECT_NAME}-data"
export LAMBDA_ROLE_NAME="${PROJECT_NAME}-lambda-role"
export LAMBDA_FUNCTION_NAME="${PROJECT_NAME}-handler"
export API_NAME="${PROJECT_NAME}-api"

# Domain settings
export DOMAIN_NAME="api.yourdomain.com"
export HOSTED_ZONE_ID="YOUR_ZONE_ID"
export CERTIFICATE_ARN="arn:aws:acm:us-east-1:${AWS_ACCOUNT_ID}:certificate/YOUR_CERT_ID"

# Runtime settings
export LAMBDA_RUNTIME="nodejs18.x"
export LAMBDA_HANDLER="handlers/index.handler"
export LAMBDA_TIMEOUT=30
export LAMBDA_MEMORY=256
```

### DynamoDB Deploy Script

```bash
#!/bin/bash
# scripts/deploy-dynamodb.sh
set -e
source "$(dirname "$0")/config.sh"

echo "==> Deploying DynamoDB table: $TABLE_NAME"

# Check if table exists
if aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null; then
    echo "Table already exists, skipping creation"
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions \
            AttributeName=PK,AttributeType=S \
            AttributeName=SK,AttributeType=S \
        --key-schema \
            AttributeName=PK,KeyType=HASH \
            AttributeName=SK,KeyType=RANGE \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION"

    echo "Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME"
fi

echo "==> DynamoDB table ready: $TABLE_NAME"
```

### IAM Deploy Script

```bash
#!/bin/bash
# scripts/deploy-iam.sh
set -e
source "$(dirname "$0")/config.sh"

echo "==> Setting up IAM role: $LAMBDA_ROLE_NAME"

# Create role if it doesn't exist
if aws iam get-role --role-name "$LAMBDA_ROLE_NAME" 2>/dev/null; then
    echo "Role already exists"
else
    aws iam create-role \
        --role-name "$LAMBDA_ROLE_NAME" \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "lambda.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }]
        }'

    # Wait for role to propagate
    sleep 10
fi

# Attach basic execution policy
aws iam attach-role-policy \
    --role-name "$LAMBDA_ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
    2>/dev/null || true

# Create and attach DynamoDB policy (least privilege)
DYNAMO_POLICY_NAME="${PROJECT_NAME}-dynamo-policy"
POLICY_DOC=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan"
        ],
        "Resource": "arn:aws:dynamodb:${AWS_REGION}:${AWS_ACCOUNT_ID}:table/${TABLE_NAME}"
    }]
}
EOF
)

# Create inline policy
aws iam put-role-policy \
    --role-name "$LAMBDA_ROLE_NAME" \
    --policy-name "$DYNAMO_POLICY_NAME" \
    --policy-document "$POLICY_DOC"

export LAMBDA_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE_NAME}"
echo "==> IAM role ready: $LAMBDA_ROLE_ARN"
```

### Lambda Deploy Script

```bash
#!/bin/bash
# scripts/deploy-lambda.sh
set -e
source "$(dirname "$0")/config.sh"

echo "==> Building Lambda function"

# Build TypeScript
npm run build

# Create deployment package
rm -f function.zip
cd dist && zip -r ../function.zip . && cd ..
zip -ur function.zip node_modules

LAMBDA_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE_NAME}"

echo "==> Deploying Lambda: $LAMBDA_FUNCTION_NAME"

# Check if function exists
if aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" 2>/dev/null; then
    echo "Updating existing function..."
    aws lambda update-function-code \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --zip-file fileb://function.zip

    aws lambda update-function-configuration \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --runtime "$LAMBDA_RUNTIME" \
        --handler "$LAMBDA_HANDLER" \
        --timeout "$LAMBDA_TIMEOUT" \
        --memory-size "$LAMBDA_MEMORY" \
        --environment "Variables={TABLE_NAME=$TABLE_NAME}"
else
    echo "Creating new function..."
    aws lambda create-function \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --runtime "$LAMBDA_RUNTIME" \
        --role "$LAMBDA_ROLE_ARN" \
        --handler "$LAMBDA_HANDLER" \
        --timeout "$LAMBDA_TIMEOUT" \
        --memory-size "$LAMBDA_MEMORY" \
        --zip-file fileb://function.zip \
        --environment "Variables={TABLE_NAME=$TABLE_NAME}"
fi

# Set concurrency limit (cost protection)
aws lambda put-function-concurrency \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --reserved-concurrent-executions 50

echo "==> Lambda deployed: $LAMBDA_FUNCTION_NAME"
```

### API Gateway Deploy Script

```bash
#!/bin/bash
# scripts/deploy-api-gateway.sh
set -e
source "$(dirname "$0")/config.sh"

echo "==> Setting up API Gateway: $API_NAME"

# Get or create REST API
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text)

if [ -z "$API_ID" ]; then
    echo "Creating new API..."
    API_ID=$(aws apigateway create-rest-api \
        --name "$API_NAME" \
        --description "API for $PROJECT_NAME" \
        --endpoint-configuration types=REGIONAL \
        --query 'id' --output text)
fi

echo "API ID: $API_ID"

# Get root resource ID
ROOT_ID=$(aws apigateway get-resources --rest-api-id "$API_ID" --query "items[?path=='/'].id" --output text)

# Helper function to create resource
create_resource() {
    local parent_id=$1
    local path_part=$2

    local resource_id=$(aws apigateway get-resources --rest-api-id "$API_ID" \
        --query "items[?pathPart=='$path_part'].id" --output text)

    if [ -z "$resource_id" ]; then
        resource_id=$(aws apigateway create-resource \
            --rest-api-id "$API_ID" \
            --parent-id "$parent_id" \
            --path-part "$path_part" \
            --query 'id' --output text)
    fi
    echo "$resource_id"
}

# Helper function to create method + integration
create_method() {
    local resource_id=$1
    local http_method=$2

    # Create method
    aws apigateway put-method \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method" \
        --authorization-type "NONE" \
        2>/dev/null || true

    # Create Lambda integration
    LAMBDA_ARN="arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${LAMBDA_FUNCTION_NAME}"

    aws apigateway put-integration \
        --rest-api-id "$API_ID" \
        --resource-id "$resource_id" \
        --http-method "$http_method" \
        --type AWS_PROXY \
        --integration-http-method POST \
        --uri "arn:aws:apigateway:${AWS_REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations"

    # Grant API Gateway permission to invoke Lambda
    aws lambda add-permission \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --statement-id "apigateway-${http_method}-$(date +%s)" \
        --action lambda:InvokeFunction \
        --principal apigateway.amazonaws.com \
        --source-arn "arn:aws:execute-api:${AWS_REGION}:${AWS_ACCOUNT_ID}:${API_ID}/*/${http_method}/*" \
        2>/dev/null || true
}

# Create /health endpoint
HEALTH_ID=$(create_resource "$ROOT_ID" "health")
create_method "$HEALTH_ID" "GET"

# Create /users endpoint
USERS_ID=$(create_resource "$ROOT_ID" "users")
create_method "$USERS_ID" "GET"
create_method "$USERS_ID" "POST"

# Create /users/{id} endpoint
USER_ID_RESOURCE=$(create_resource "$USERS_ID" "{id}")
create_method "$USER_ID_RESOURCE" "GET"
create_method "$USER_ID_RESOURCE" "PUT"
create_method "$USER_ID_RESOURCE" "DELETE"

# Deploy to prod stage
echo "Deploying to prod stage..."
aws apigateway create-deployment \
    --rest-api-id "$API_ID" \
    --stage-name prod \
    --description "Deployed by script at $(date)"

# Apply throttling
aws apigateway update-stage \
    --rest-api-id "$API_ID" \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/throttling/rateLimit,value=100 \
        op=replace,path=/throttling/burstLimit,value=200

# Export API ID for other scripts
export API_ID
echo "==> API Gateway deployed: https://${API_ID}.execute-api.${AWS_REGION}.amazonaws.com/prod"
```

### Custom Domain Deploy Script

```bash
#!/bin/bash
# scripts/deploy-custom-domain.sh
set -e
source "$(dirname "$0")/config.sh"

echo "==> Setting up custom domain: $DOMAIN_NAME"

# Get API ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text)

if [ -z "$API_ID" ]; then
    echo "ERROR: API not found. Run deploy-api-gateway.sh first."
    exit 1
fi

# Create custom domain if it doesn't exist
if aws apigateway get-domain-name --domain-name "$DOMAIN_NAME" 2>/dev/null; then
    echo "Custom domain already exists"
else
    aws apigateway create-domain-name \
        --domain-name "$DOMAIN_NAME" \
        --regional-certificate-arn "$CERTIFICATE_ARN" \
        --endpoint-configuration types=REGIONAL
fi

# Create base path mapping
aws apigateway create-base-path-mapping \
    --domain-name "$DOMAIN_NAME" \
    --rest-api-id "$API_ID" \
    --stage prod \
    2>/dev/null || echo "Base path mapping already exists"

# Get the target domain name for DNS
TARGET_DOMAIN=$(aws apigateway get-domain-name \
    --domain-name "$DOMAIN_NAME" \
    --query 'regionalDomainName' --output text)

TARGET_ZONE=$(aws apigateway get-domain-name \
    --domain-name "$DOMAIN_NAME" \
    --query 'regionalHostedZoneId' --output text)

echo "==> Creating Route 53 record..."

# Create/update DNS record
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "{
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$DOMAIN_NAME\",
                \"Type\": \"A\",
                \"AliasTarget\": {
                    \"DNSName\": \"$TARGET_DOMAIN\",
                    \"HostedZoneId\": \"$TARGET_ZONE\",
                    \"EvaluateTargetHealth\": false
                }
            }
        }]
    }"

echo "==> Custom domain ready: https://$DOMAIN_NAME"
echo "Note: DNS propagation may take a few minutes"
```

### Master Deploy Script

```bash
#!/bin/bash
# scripts/deploy-all.sh - Deploy everything in the correct order
set -e

SCRIPT_DIR="$(dirname "$0")"

echo "=========================================="
echo "  Full Deployment - $(date)"
echo "=========================================="

"$SCRIPT_DIR/deploy-dynamodb.sh"
echo ""

"$SCRIPT_DIR/deploy-iam.sh"
echo ""

"$SCRIPT_DIR/deploy-lambda.sh"
echo ""

"$SCRIPT_DIR/deploy-api-gateway.sh"
echo ""

"$SCRIPT_DIR/deploy-custom-domain.sh"
echo ""

echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Your API is available at:"
echo "  https://$DOMAIN_NAME"
echo ""
echo "Test with:"
echo "  curl https://$DOMAIN_NAME/health"
```

### Using the Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Edit config.sh with your settings
vim scripts/config.sh

# Deploy everything
./scripts/deploy-all.sh

# Or deploy individual components
./scripts/deploy-lambda.sh      # Just update Lambda code
./scripts/deploy-api-gateway.sh # Just update API Gateway
```

### Ask Claude to Generate Scripts

> "Help me create a deploy script for [component] that:
> - Checks if the resource exists before creating
> - Uses variables from config.sh
> - Handles errors gracefully
> - Outputs the resource ARN when done"

---

## Part 8: Working with Claude

### What Claude Does Well

- **Scaffolding:** "Create a Lambda handler for user registration"
- **Boilerplate:** IAM policies, CloudFormation/SAM templates
- **Debugging:** "This Lambda is returning 502, here's the CloudWatch log..."
- **Iteration:** "Add email validation to the createUser handler"

### What to Review Carefully

1. **IAM Policies** — Claude sometimes grants overly broad permissions
   - Watch for `*` in Resource fields
   - Prefer specific table ARNs over `arn:aws:dynamodb:*:*:table/*`

2. **Error Handling** — Ensure errors don't leak internal details
   - Don't return stack traces to clients
   - Log details to CloudWatch, return generic message to user

3. **Environment Variables** — Never commit secrets
   - Use AWS Secrets Manager or Parameter Store for sensitive values

4. **Costs** — Review before deploying
   - DynamoDB: Pay-per-request is safe for low traffic; provisioned for high
   - Lambda: Set concurrency limits
   - API Gateway: Throttling prevents surprise bills

### Example Prompts

**Initial setup:**
> "Help me create an AWS serverless backend with:
> - API Gateway REST API
> - Lambda functions in TypeScript
> - DynamoDB single-table design
> - Custom domain api.mydomain.com
>
> Start with the DynamoDB table and IAM role."

**Adding endpoints:**
> "Add a POST /orders endpoint to my API that:
> - Validates the request body has userId, items array, and total
> - Stores the order in DynamoDB with PK=USER#userId, SK=ORDER#timestamp
> - Returns the created order with generated orderId"

**Debugging:**
> "My Lambda is returning 502. Here's the CloudWatch error: [paste error]. The handler code is: [paste code]. What's wrong?"

---

## Quick Reference

### Useful Commands

```bash
# Test your API
curl https://api.yourdomain.com/health

# View Lambda logs
aws logs tail /aws/lambda/MyApiUsers --follow

# Update Lambda code
aws lambda update-function-code \
  --function-name MyApiUsers \
  --zip-file fileb://function.zip

# Check API Gateway stage
aws apigateway get-stage --rest-api-id YOUR_API_ID --stage-name prod
```

### Cost Estimates (Low Traffic)

| Service | Free Tier | After Free Tier |
|---------|-----------|-----------------|
| Route 53 | $0.50/month (hosted zone) | Same |
| ACM | Free | Free |
| API Gateway | 1M requests/month | ~$3.50/million |
| Lambda | 1M requests + 400K GB-seconds | ~$0.20/million |
| DynamoDB | 25 GB + 25 WCU/RCU | Pay-per-request: ~$1.25/million reads |

For a small app with <100K requests/month, expect **$1-5/month** total.

---

## Next Steps

Once your API is running:

1. **Add Authentication** — See the Cognito/OAuth guide (separate document)
2. **Set Up CI/CD** — GitHub Actions or AWS CodePipeline
3. **Add Monitoring** — CloudWatch dashboards, X-Ray tracing
4. **Consider CDK/SAM** — Infrastructure as code for reproducibility

---

*This guide focuses on manual setup to understand the components. For production, consider AWS SAM or CDK for infrastructure-as-code.*
