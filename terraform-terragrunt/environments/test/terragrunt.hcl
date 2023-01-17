inputs = {
    environment     = "test"
    region          = "us-east-1"
    name            = "technofex-test"
    vpc_id          = "vpc-02434178"
    subnet_ids      = ["subnet-efc330b0", "subnet-cf2dab82"]

    frontend_container_port = "5000"
    backend_container_port  = "3000"
}
