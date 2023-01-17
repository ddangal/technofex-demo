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

variable "subnet_ids" {
  description = "list of subnet ids"
  type        = list
}

variable "frontend-lb-sg" {
  description = "frontend load balance SG"
}

variable "frontend-service-sg" {
  description = "frontend service SG"
}

variable "frontend-container-port" {
  description = "container port to access"
  default = 3000
}

variable "ecr-uri" {
  description = "URI of ECR repository"
}

variable "ecs-task-role" {
  description = "ECS task role"
}

variable "ecs-cluster-id" {
  description = "ECS cluster id"
}


resource "aws_lb" "frontend-lb" {
  name               = format("%s-frontend-lb", var.name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.frontend-lb-sg]
  subnets            = var.subnet_ids
  
}


resource "aws_lb_target_group" "frontend-tg" {
  name        = format("%s-frontend-tg", var.name)
  port        = var.frontend-container-port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  depends_on = [aws_lb.frontend-lb]
}


resource "aws_lb_listener" "frontend-listener" {
  load_balancer_arn = aws_lb.frontend-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-tg.arn
  }
}

resource "aws_cloudwatch_log_group" "frontend-log-group" {
  name        = format("%s-frontend-log-group", var.name)
}

resource "aws_ecs_task_definition" "frontend-td" {
  family                   = format("%s-frontend-task-def", var.name)
  container_definitions    = <<DEFINITION
    [{
      "name": "frontend-service",
      "image": "${format("%s:latest", var.ecr-uri)}",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.frontend-container-port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.frontend-log-group.name}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix":"ecs"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = var.ecs-task-role
  execution_role_arn       = var.ecs-task-role
}

resource "aws_ecs_service" "frontend-ecs-service" {
  name                               = format("%s-frontend-service", var.name)
  task_definition                    = aws_ecs_task_definition.frontend-td.family
  desired_count                      = 1
  launch_type                        = "FARGATE"
  cluster                            = var.ecs-cluster-id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    security_groups  = [var.frontend-service-sg]
    subnets          = var.subnet_ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend-tg.arn
    container_name   = "frontend-service"
    container_port   = var.frontend-container-port
  }
}
