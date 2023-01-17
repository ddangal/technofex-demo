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
  source = "../../..//_layers/database"
}

dependency "supporting-resources" {
    config_path = "../supporting-resources"
}

inputs = {
    rds-sg-id = dependency.supporting-resources.outputs.rds-sg-id
}