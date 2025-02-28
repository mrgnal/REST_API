#Sg for ECR endpoint
resource "aws_security_group" "endpoint_sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      security_groups = [aws_security_group.ecs_service_sg.id]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
 }

# Sg for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# Sg for ECR service
resource "aws_security_group" "ecs_service_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# Sg for rds
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress  {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
  egress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}