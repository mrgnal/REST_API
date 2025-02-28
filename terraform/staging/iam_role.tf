#   Execution task role
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsExecurionTaskRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
          }
        ]
      })
}

resource "aws_iam_policy" "ecs_execution_ssm_policy" {
  name = "ecs-execution-ssm-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt",
      ]
      Resource = [
        aws_ssm_parameter.db_name.arn,
        aws_ssm_parameter.db_host.arn,
        aws_ssm_parameter.db_username.arn,
        aws_ssm_parameter.db_password.arn,
        aws_ssm_parameter.drf_secret_key.arn,
      ]
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
  name = "ecs-execution-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_ssm_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_ssm_policy.arn
}
