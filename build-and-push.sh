#!/bin/bash

# Configurações
AWS_REGION="us-east-1"
ECR_REPOSITORY="next-cloud"
IMAGE_TAG="latest"

# Obter account ID da AWS
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# URI completa do ECR
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "Building Docker image..."
docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

echo "Tagging image for ECR..."
docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

echo "Pushing image to ECR..."
docker push ${ECR_URI}:${IMAGE_TAG}

echo "Image pushed successfully to: ${ECR_URI}:${IMAGE_TAG}"
