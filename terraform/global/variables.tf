variable "region" {
    description = "AWS region"
    type = string
    default = "eu-north-1"
}

variable "env" {
    description = "Enviroment workflow"
    type  = string
}

variable "backend_bucket_name" {
    description = "S3 name for backend"
    type = string
}

variable "ecr_repo_name" {
    description = "Docker image repo"
    type = string
}

variable "ecs_service_name" {
    type = string
}

variable "ecs_cluster_name" {
    type = string
}


# variable "repo_owner" {
#   description = "GitHub repo owner"
# }

# variable "repo_name" {
#   description = "GitHub repo name"
# }
