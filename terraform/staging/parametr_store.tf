resource "aws_ssm_parameter" "db_host" {
    name = "/staging/myapp/db_host"
    type = "String"
    value = aws_db_instance.mydb.address
}

resource "aws_ssm_parameter" "db_username" {
    name = "/staging/myapp/db_user"
    type = "String"
    value = var.db_user
}

resource "random_password" "password_generator" {
    length = 15
    special = false
}

resource "aws_ssm_parameter" "db_password" {
    name = "/staging/myapp/db_password"
    type = "SecureString"
    value = random_password.password_generator.result
}

resource "aws_ssm_parameter" "db_name" {
       name = "/staging/myapp/db_name"
       type = "String"
       value = var.db_name
}

resource "aws_ssm_parameter" "drf_secret_key" {
    name = "/staging/myapp/secret_key"
    type = "SecureString"
    value = var.secret_key
}