#! /bin/bash

export VPC_STACK="eks-vpc-stack"

# Stack outputs 가져오기
outputs=$(aws cloudformation describe-stacks --stack-name $VPC_STACK --query "Stacks[0].Outputs" --output json)

# 개별 값 추출
export VPC_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="VPCId").OutputValue')
export PRIVATE_SUBNET_1_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet1Id").OutputValue')
export PRIVATE_SUBNET_2_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet2Id").OutputValue')
export PRIVATE_SUBNET_3_ID=$(echo $outputs | jq -r '.[] | select(.OutputKey=="PrivateSubnet3Id").OutputValue')

export CLUSTER_NAME="mesh-manager-eks"
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 이 부분은 private cluster endpoint로 접근 허용할 CIDR을 적을 것
export ALLOWED_CIDR="10.10.0.0/16"

# 결과 출력
echo "VPC_STACK: $VPC_STACK"
echo "VPC_ID: $VPC_ID"
echo "PRIVATE_SUBNET_1_ID (AZ-a): $PRIVATE_SUBNET_1_ID"
echo "PRIVATE_SUBNET_2_ID (AZ-b): $PRIVATE_SUBNET_2_ID"
echo "PRIVATE_SUBNET_3_ID (AZ-c): $PRIVATE_SUBNET_3_ID"



envsubst < eks.yaml > eks-prac-env-add.yaml

eksctl create cluster -f eks-prac-env-add.yaml

echo "Cluster Creation Complete!"

export eks_sg=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
echo "Security Group ID: $eks_sg" 

aws ec2 authorize-security-group-ingress --group-id $eks_sg --protocol tcp --port 443 --cidr $ALLOWED_CIDR

echo "Setting alb Configuration"
sleep 3;

eksctl create iamserviceaccount  \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

#Helm Repo Update

helm repo add eks https://aws.github.io/eks-charts
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
	-n kube-system \
	--set clusterName=$CLUSTER_NAME \
	--set serviceAccount.create=false \
	--set serviceAccount.name=aws-load-balancer-controller \
	--set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller \
	--set region=ap-northeast-2 \
	--set vpcId=$VPC_ID
