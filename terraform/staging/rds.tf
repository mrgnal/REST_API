resource "aws_db_subnet_group" "rds_subnet_group" {
    name = "rds-subnet-group"
    subnet_ids = [aws_subnet.PrivateSubnet-2.id, aws_subnet.PrivateSubnet-1.id]

}

resource "aws_db_instance" "mydb" {
    identifier =  "my-postgres-db"
    allocated_storage = 20
    engine = "postgres"
    engine_version = "16.4"
    instance_class = "db.t3.micro"
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    publicly_accessible = false
    skip_final_snapshot = true
    multi_az = false
    storage_encrypted = true
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    db_name = aws_ssm_parameter.db_name.value
    username = aws_ssm_parameter.db_username.value
    password = aws_ssm_parameter.db_password.value
}