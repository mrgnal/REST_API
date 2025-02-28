#github user auth
# output "github_access_key_id" {
#     value = aws_iam_access_key.github_actions_user_key.id
#   }
#
# output "github_secret_access_key" {
#       value     = aws_iam_access_key.github_actions_user_key.secret
#       sensitive = true
#   }

output "ecr_repo_url" {
    value = aws_ecr_repository.practice_ecr.repository_url
}
