resource "aws_iam_user" "github_actions_user" {
  name = "github-actions-user"
  path = "/github/"
}

resource "aws_iam_access_key" "github_actions_user_key" {
  user = aws_iam_user.github_actions_user.name
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_access_policy" {

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
        "ecs:DescribeTaskDefinition"
    ]
    resources = ["*" ]
 }
 statement {
   effect    = "Allow"
   actions   = ["iam:PassRole"]
   resources = ["*"]
 }

  statement {
    effect    = "Allow"
    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repo_name}"
    ]
  }

    statement {
      effect    = "Allow"
      actions   = [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:ListClusters",
        "ecs:DescribeClusters",
        "ecs:RegisterTaskDefinition",
        "ecs:ListTaskDefinitions",
        "ecs:RunTask",
        "ecs:StartTask",
        "ecs:DescribeTasks"
      ]
      resources = [
        "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}",
        "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/*"
      ]
    }
}

# resource "aws_iam_openid_connect_provider" "github" {
#   url = ""
#   client_id_list = ["sts.amazonaws.com"]
#   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
# }

# resource "aws_iam_role" "github_actions_role" {
#   name = "github-actions-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.github.arn
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
#             "token.actions.githubusercontent.com:sub" = "repo:${var.repo_owner}/${var.repo_name}:ref:refs/heads/main"
#           }
#         }
#       }
#     ]
#   })
# }


resource "aws_iam_user_policy" "ecr_access" {
  name   = "ecr-access-policy"
  user   = aws_iam_user.github_actions_user.name
  policy = data.aws_iam_policy_document.ecr_access_policy.json
}