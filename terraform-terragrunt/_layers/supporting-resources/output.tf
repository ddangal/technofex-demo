output "rds-sg-id" {
    value =aws_security_group.rds.id
}

output "backend-service-sg-id" {
    value =aws_security_group.backend-service.id
}

output "backend-lb-sg-id" {
    value =aws_security_group.backend-lb.id
}


output "frontend-service-sg-id" {
    value =aws_security_group.frontend-service.id
}


output "frontend-lb-sg-id" {
    value =aws_security_group.frontend-lb.id
}

output "frontend-ecr" {
    value = aws_ecr_repository.frontend-ecr.repository_url
}

output "backend-ecr" {
    value = aws_ecr_repository.backend-ecr.repository_url
}

output "ecs-task-role" {
    value = aws_iam_role.ecs-task-execution-role.arn
}

output "ecs-cluster-id" {
    value = aws_ecs_cluster.fargate.id
}