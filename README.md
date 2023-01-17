# Overview

 The repository presents a sample demo microservice architecture and its implmentation. 

## About the Repository
 The repository contains all codes/scripts required for this sample micorservice to run. The whole application has been divided into **web layer(frontend)**, **application layer(backend)** and **data layer(database).** 
```
├── python-app
├── react-app
└── terraform-terragrunt
```
*Note: we will be mostly working on terraform-terragrunt layer as a part of our DevOps practice. We may need to update few settings in the frontend(react-app) and backend(python-app) inorder to use the new endpoints created from terraform.*

## Sample Architecture Diagram
![alt text](https://github.com/ddangal/technofex-demo/blob/master/Sample%20Microservice%20Architecture.png?raw=true)
*Note: Route53 and SSL setup has not been implemented on actual terraform/terragrunt setup due to domain.*

## About Terraform/Terragrunt
* **Terraform:** Terraform is an open-source infrastructure-as-code software tool created by HashiCorp. Users define and provide data center infrastructure using a declarative configuration language. For more: https://www.terraform.io/

* **Terragrunt:** Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state. For more:  https://terragrunt.gruntwork.io/
#### Setup Terraform and terragrunt
* Download and install both terraform and terragrunt using the links given above
* Setup AWS CLI: https://aws.amazon.com/cli/

#### Terraform/Terragrunt structure in this repository: 
```
├── environments
│   ├── prod
│   └── test
│       ├── applications
│       │   ├── backend
│       │   │   └── terragrunt.hcl
│       │   └── frontend
│       │       └── terragrunt.hcl
│       ├── database
│       │   └── terragrunt.hcl
│       ├── supporting-resources
│       │   └── terragrunt.hcl
│       └── terragrunt.hcl
└── _layers
    ├── applications
    │   ├── backend
    │   │   ├── main.tf
    │   │   └── output.tf
    │   └── frontend
    │       ├── main.tf
    │       └── output.tf
    ├── database
    │   ├── main.tf
    │   └── output.tf
    └── supporting-resources
        ├── main.tf
        └── output.tf

```
*Note: Please go through the official terragrunt documentation once in order to understand and implement the above structure*

#### Deploying infrastructure with terraform/terragrunt
```
├── applications
├── database
└── supporting-resources
```
* The resources which needs to be deployed are dividied into three layers.

* The first layer that needs to be deployed is `supporting-resources` which contains all necessary resources such as `security groups, iam roles/policies, ecr repositories` and so on. 

* Once `supporting-resources` has been deployed, we need to deploy `database` layer which consists all an RDS database. 

* Before deploying the application itself, we need to push docker images to the ECR repositories created on first step. Remember to update the database endpoints before building docker images

* Finally deploy `applications/backend` layer and `applications/frontend` layer. 

#### Sample deployment example 
```
cd environments/test/supporting-resources
terragrunt init
terragrunt apply
```

### Further Improvements:
This is just a sample demo application designed to run on a test environment. Here are few enhancements we can do for better scalability, security and performance for production work loads: 
* we can have Database on private subnet with NAT for better security
* We can enable autoscaling on ECS service inorder to reduce downtime and better performance
* We can enable logging and monitoring for better visibility of our system
* <to-do....>
# 
                          Copyright © 2023 https://github.com/ddangal
