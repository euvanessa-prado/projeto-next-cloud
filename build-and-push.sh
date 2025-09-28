#!/bin/bash

# Edite aqui seu profile AWS se necessário
PROFILE="bia"

echo "🔍 Verificando profile AWS..."
aws sts get-caller-identity --profile $PROFILE

aws ecr get-login-password --profile $PROFILE --region us-east-1 | docker login --username AWS --password-stdin 448522291635.dkr.ecr.us-east-1.amazonaws.com

docker build -t next-cloud .

docker tag next-cloud:latest 448522291635.dkr.ecr.us-east-1.amazonaws.com/next-cloud:latest

docker push 448522291635.dkr.ecr.us-east-1.amazonaws.com/next-cloud:latest
