terraform {
    required_version = ">0.13.7"
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 3.36.0"
      }
    }
    
    backend "s3" {   
    }
}

provider "aws" {
  region = var.region
}

variable "region" {
    description = "aws region"
}

variable "name" {
  description = "suffix for the resource"
}

variable "vpc_id" {
  description = "VPC id"
}

/**
 * security groups
 */
resource "aws_security_group" "rds" {
  name        = format("%s-rds-sg", var.name)
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [aws_security_group.frontend-service.id, aws_security_group.frontend-service.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend-service" {
  name        = format("%s-backend-service-sg", var.name)
  description = "Security group for backend ECS service"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    security_groups = [aws_security_group.backend-lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend-service" {
  name        = format("%s-frontend-service-sg", var.name)
  description = "Security group for frontend ECS service"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    security_groups = [aws_security_group.frontend-lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend-lb" {
  name        = format("%s-backend-lb-sg", var.name)
  description = "Security group for backend LB"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend-lb" {
  name        = format("%s-frontend-lb-sg", var.name)
  description = "Security group for frontend ECS service"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/** ECR */
resource "aws_ecr_repository" "frontend-ecr" {
  name                 = format("%s-frontend-repo", var.name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "backend-ecr" {
  name                 = format("%s-backend-repo", var.name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

/** ECS role/policies */
data "aws_iam_policy_document" "ecs-task-execution-policy" {
  statement {
    effect = "Allow"

    actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = format("%s-task-role", var.name)
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_role_policy" "ecs-task-execution-policy" {
  name   = format("%s-task-role", var.name)
  role   = aws_iam_role.ecs-task-execution-role.id
  policy = data.aws_iam_policy_document.ecs-task-execution-policy.json
}

/** ECS fargate cluster */
resource "aws_ecs_cluster" "fargate" {
  name = format("%s-cluster", var.name)
}