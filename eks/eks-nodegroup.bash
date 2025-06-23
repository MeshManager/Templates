#! /bin/bash

export CLUSTER_NAME="mesh-manager-eks"

eksctl create nodegroup --config-file=./eks-nodegroup.yaml

echo "기존 노드그룹 목록:"
eksctl get nodegroups --cluster=$CLUSTER_NAME --output=json | jq -r '.[]'

read -p "삭제할 노드그룹 이름을 입력하세요: " OLD_NODEGROUP

kubectl taint nodes -l "eks.amazonaws.com/nodegroup=$OLD_NODEGROUP" key=value:NoExecute

eksctl drain nodegroup --cluster $CLUSTER_NAME --name $OLD_NODEGROUP


eksctl delete nodegroup --cluster $CLUSTER_NAME --name $OLD_NODEGROUP