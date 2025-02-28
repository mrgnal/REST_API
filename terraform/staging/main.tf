terraform {

    backend "s3" {
          bucket         = "mg-practice-task"
          key            = "staging/terraform.tfstate"
          region         = "eu-north-1"
          dynamodb_table = "terraform-state-locking"
          encrypt        = true
        }

  required_providers {
      aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      }
  }
}

provider "aws" {
    region = var.region
}

data "terraform_remote_state" "global" {
    backend = "s3"
    config = {
      bucket = var.backend_bucket_name
      key    = "global/terraform.tfstate"
      region = var.region
    }
}

#ECS
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "practice-staging-claster"

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}


resource "aws_ecs_task_definition" "app_conteiner" {
    family = "app-service"
    network_mode = "awsvpc"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    cpu = "512"
    memory = "1024"
    requires_compatibilities = ["FARGATE"]
    container_definitions = jsonencode([
        {
            name = "my-app"
            image = "${data.terraform_remote_state.global.outputs.ecr_repo_url}:latest"
            essential = true
            portMappings = [
                {
                containerPort = 80
                hostPort=80
                }
            ]
            secrets =[
                {name = "DB_HOST", valueFrom = aws_ssm_parameter.db_host.arn},
                {name = "DB_NAME", valueFrom = aws_ssm_parameter.db_name.arn},
                {name = "DB_USERNAME", valueFrom = aws_ssm_parameter.db_username.arn},
                {name = "DB_PASSWORD", valueFrom = aws_ssm_parameter.db_password.arn},
                {name = "SECRET_KEY", valueFrom = aws_ssm_parameter.drf_secret_key.arn},
            ]
        }
    ])
}

resource "aws_ecs_service" "app_conteiner_service" {
    name = "staging-app-service"
    depends_on = [aws_db_instance.mydb]
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.app_conteiner.id
    desired_count = 3
    launch_type = "FARGATE"
    force_new_deployment = true

    load_balancer {
      target_group_arn = aws_alb_target_group.ecs_tg.arn
      container_port = 80
      container_name = "my-app"
    }

    network_configuration {
      assign_public_ip = false
      subnets = [aws_subnet.PrivateSubnet-1.id, aws_subnet.PrivateSubnet-2.id]
      security_groups = [aws_security_group.ecs_service_sg.id]
    }
}

# AlB
resource "aws_alb" "alb" {
    name = "alb-for-esc-staging"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.PublicSubnet-2.id, aws_subnet.PublicSubnet-1.id]
    enable_deletion_protection = false
}

resource "aws_alb_listener" "alb_listener" {
    load_balancer_arn = aws_alb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_alb_target_group.ecs_tg.arn
    }
  }

resource "aws_alb_target_group" "ecs_tg" {
    name = "tg-for-ecs"
    vpc_id = aws_vpc.main_vpc.id
    port = 80
    protocol = "HTTP"
    target_type = "ip"
}

# Autoscale
resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = 6
    min_capacity       = 2
    resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.app_conteiner_service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
  }

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
    name               = "ecs-policy-cpu"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
      target_value       = 50.0
      predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
      }
          scale_in_cooldown  = 60
          scale_out_cooldown = 60
        }
}
