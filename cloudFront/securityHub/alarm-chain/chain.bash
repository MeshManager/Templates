#! /bin/bash

# 파라미터 값 변수에 할당
read -p "slack web Hook URL을 입력하세요: " PARAM_URL

# CloudFormation 스택 생성
aws cloudformation create-stack \
  --stack-name security-hub-alarm-chain \
  --template-body file://$(pwd)/chain.yaml \
  --parameters ParameterKey=SlackWebhookUrl,ParameterValue=${PARAM_URL} \
  --capabilities CAPABILITY_NAMED_IAM
