#! /bin/bash

# 파라미터 값 변수에 할당
read -p "slack web Hook URL을 입력하세요: " PARAM_URL

# CloudFormation 스택 생성
aws cloudformation create-stack \
  --stack-name security-hub-alarm-chain \
  --template-body file://$(pwd)/chain.yaml \
  --parameters ParameterKey=SlackWebhookUrl,ParameterValue=${PARAM_URL} \
  --capabilities CAPABILITY_NAMED_IAM


CRON_JOB="0 7 * * * /root/.local/bin/prowler aws --security-hub --send-sh-only-fails -f ap-northeast-2"

# 이미 등록되어 있는지 확인
crontab -l 2>/dev/null | grep -F "$CRON_JOB" > /dev/null
if [ $? -eq 0 ]; then
  echo "이미 크론탭에 등록되어 있습니다."
else
  # 기존 크론탭 백업 후 새 라인 추가
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "크론탭에 등록 완료: $CRON_JOB"
fi