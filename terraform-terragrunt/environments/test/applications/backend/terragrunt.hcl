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
  source = "../../../..//_layers/applications/backend"
}


dependency "supporting-resources" {
    config_path = "../../supporting-resources"
}

inputs = {
    backend-lb-sg = dependency.supporting-resources.outputs.backend-lb-sg-id
    backend-service-sg = dependency.supporting-resources.outputs.backend-service-sg-id
    ecr-uri        = dependency.supporting-resources.outputs.backend-ecr
    ecs-task-role  = dependency.supporting-resources.outputs.ecs-task-role
    ecs-cluster-id = dependency.supporting-resources.outputs.ecs-cluster-id
}