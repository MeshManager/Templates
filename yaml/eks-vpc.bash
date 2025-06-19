#! /bin/bash

aws cloudformation create-stack --stack-name eks-vpc-stack --template-body ./eks-vpc.yaml