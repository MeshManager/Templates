#! /bin/bash

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

envsubst < dynamodb-iam.yaml > dynamodb-iam-env-add.yaml

# DynamoDB 정책 생성
aws cloudformation create-stack \
  --stack-name teleport-dynamodb-policy \
  --template-body file://dynamodb-iam.yaml \

# S3 정책 생성
aws cloudformation create-stack \
  --stack-name teleport-s3-policy \
  --template-body file://s3-iam.yaml \