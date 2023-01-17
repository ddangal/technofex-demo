include {
    path = find_in_parent_folders()
}

remote_state {
  backend = "s3"
  config = {
    bucket          = "terragrunt-test-technofex"
    region          = "us-east-1"
    key             = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table  = "terragrunt-test"
  }
}

terraform {
  source = "../../../..//_layers/applications/frontend"
}


dependency "supporting-resources" {
    config_path = "../../supporting-resources"
}

inputs = {
    frontend-lb-sg = dependency.supporting-resources.outputs.frontend-lb-sg-id
    frontend-service-sg = dependency.supporting-resources.outputs.frontend-service-sg-id
    ecr-uri        = dependency.supporting-resources.outputs.frontend-ecr
    ecs-task-role  = dependency.supporting-resources.outputs.ecs-task-role
    ecs-cluster-id = dependency.supporting-resources.outputs.ecs-cluster-id
}