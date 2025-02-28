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

variable "db_user" {
    description = "DB username"
    type = string
}

variable "db_name" {
   description = "DB name"
   type = string
}

variable "secret_key" {
    description = "DRF secret key"
    type = string
}