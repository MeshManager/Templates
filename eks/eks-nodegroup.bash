#! /bin/bash

export CLUSTER_NAME="mesh-manager-eks"

eksctl create nodegroup --config-file=./eks-prac-add-env.yaml

#eksctl create nodegroup \
#  --cluster demo-eks-cluster \
#  --name demo-nodegroup2 \
#  --node-type t3.medium \
#  --nodes 2 \
#  --nodes-min 2 \
#  --nodes-max 5 \
#  --node-private-networking \
#  --subnet-ids subnet-01d6aa00d542040c2,subnet-03d5f4e404bc215a0

echo "기존 노드그룹 목록:"
eksctl get nodegroups --cluster=$CLUSTER_NAME --output=json | jq -r '.[]'

read -p "삭제할 노드그룹 이름을 입력하세요: " OLD_NODEGROUP

kubectl taint nodes -l "eks.amazonaws.com/nodegroup=$OLD_NODEGROUP" key=value:NoExecute

eksctl drain nodegroup --cluster $CLUSTER_NAME --name $OLD_NODEGROUP


eksctl delete nodegroup --cluster $CLUSTER_NAME --name $OLD_NODEGROUP