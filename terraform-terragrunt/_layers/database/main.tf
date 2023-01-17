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

variable "rds-sg-id" {
  description = "SG id for RDS"
}

variable "db-password" {
  description = "password for database user"
}

resource "aws_db_subnet_group" "main" {
  name = "technofexdb"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "main" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.main.id
  vpc_security_group_ids = [var.rds-sg-id]
}
