#! /bin/bash

# VPC 추출
export VPC_STACK="eks-vpc-stack"
outputs=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --query "Stacks[0].Outputs" --output json)

export VPC_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="VPCId").OutputValue')

export PRIVATE_DB_SUBNET_1_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet1Id").OutputValue')
export PRIVATE_DB_SUBNET_2_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet2Id").OutputValue')
export PRIVATE_DB_SUBNET_3_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet3Id").OutputValue')

export CLUSTER_NAME="mesh-manager-eks"
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 결과 출력
echo "VPC_STACK: $VPC_STACK"
echo "VPC_ID: $VPC_ID"
echo "PRIVATE_DB_SUBNET_1_ID (AZ-a): $PRIVATE_DB_SUBNET_1_ID"
echo "PRIVATE_DB_SUBNET_2_ID (AZ-b): $PRIVATE_DB_SUBNET_2_ID"
echo "PRIVATE_DB_SUBNET_3_ID (AZ-c): $PRIVATE_DB_SUBNET_3_ID"

# 보안그룹 세팅
export EKS_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
echo "EKS Security Group ID: $EKS_SG"

envsubst < efs.yaml > efs-env-add.yaml

# EFS driver 정책 설정
eksctl create iamserviceaccount \
    --name efs-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --role-name $ROLE_NAME \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --approve

eksctl create addon --cluster $CLUSTER_NAME --name  aws-efs-csi-driver --version latest \
    --service-account-role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME --force


# EFS 생성
aws cloudformation create-stack --stack-name efs-eks-stack --template-body file://$(pwd)/efs-env-add.yaml


# 참조
# https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-efs-filesystem.html


