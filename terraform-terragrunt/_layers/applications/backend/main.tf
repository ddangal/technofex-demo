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

variable "backend-lb-sg" {
  description = "backend load balance SG"
}

variable "backend-service-sg" {
  description = "backend service SG"
}

variable "backend-container-port" {
  description = "container port to access"
  default = 5000
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


resource "aws_lb" "backend-lb" {
  name               = format("%s-backend-lb", var.name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.backend-lb-sg]
  subnets            = var.subnet_ids
  
}


resource "aws_lb_target_group" "backend-tg" {
  name        = format("%s-backend-tg", var.name)
  port        = var.backend-container-port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  depends_on = [aws_lb.backend-lb]
}


resource "aws_lb_listener" "backend-listener" {
  load_balancer_arn = aws_lb.backend-lb.arn
  port              = "5000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend-tg.arn
  }
}

resource "aws_cloudwatch_log_group" "backend-log-group" {
  name        = format("%s-backend-log-group", var.name)
}

resource "aws_ecs_task_definition" "backend-td" {
  family                   = format("%s-backend-task-def", var.name)
  container_definitions    = <<DEFINITION
    [{
      "name": "backend-service",
      "image": "${format("%s:latest", var.ecr-uri)}",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.backend-container-port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.backend-log-group.name}",
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

resource "aws_ecs_service" "backend-ecs-service" {
  name                               = format("%s-backend-service", var.name)
  task_definition                    = aws_ecs_task_definition.backend-td.family
  desired_count                      = 1
  launch_type                        = "FARGATE"
  cluster                            = var.ecs-cluster-id
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    security_groups  = [var.backend-service-sg]
    subnets          = var.subnet_ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend-tg.arn
    container_name   = "backend-service"
    container_port   = var.backend-container-port
  }
}
