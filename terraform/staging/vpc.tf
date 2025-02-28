resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "vpc-practice-staging"
    }

}

#Subnets
resource "aws_subnet" "PublicSubnet-1" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = "10.0.1.0/24"
}


resource "aws_subnet" "PublicSubnet-2" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = "${var.region}b"
    cidr_block = "10.0.2.0/24"
}

resource "aws_subnet" "PrivateSubnet-1" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = "${var.region}a"
    cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "PrivateSubnet-2" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = "${var.region}b"
    cidr_block = "10.0.4.0/24"
}

#Public subnets
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "PublicRT" {
vpc_id = aws_vpc.main_vpc.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
}

resource "aws_route_table_association" "PublicRTAssociation-1" {
    subnet_id  = aws_subnet.PublicSubnet-1.id
    route_table_id = aws_route_table.PublicRT.id
}

resource "aws_route_table_association" "PublicRTAssociation-2" {
    subnet_id      = aws_subnet.PublicSubnet-2.id
    route_table_id = aws_route_table.PublicRT.id
}

#Endpoints

resource "aws_vpc_endpoint" "s3_endpoint" {
    vpc_id       = aws_vpc.main_vpc.id
    service_name = "com.amazonaws.${var.region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.PrivateRT.id]
}


locals {
    services = {
        "ec2messages" : {
          "name" : "com.amazonaws.${var.region}.ec2messages"
        },
        "ssm" : {
          "name" : "com.amazonaws.${var.region}.ssm"
        },
        "ssmmessages" : {
          "name" : "com.amazonaws.${var.region}.ssmmessages"
        }

        "dkr" : {
            "name" : "com.amazonaws.${var.region}.ecr.dkr"
        }
        "ecs-telemetry" : {
            "name" : "com.amazonaws.${var.region}.ecs-telemetry"
        }
        "ecs-agent" : {
            "name" : "com.amazonaws.${var.region}.ecs-agent"
        }
        "api" : {
            "name" : "com.amazonaws.${var.region}.ecr.api"
        }
      }
    }

resource "aws_vpc_endpoint" "endpoints_for_ecs" {
    for_each = local.services
    vpc_id   = aws_vpc.main_vpc.id
    service_name        = each.value.name
    vpc_endpoint_type   = "Interface"
    security_group_ids  = [aws_security_group.endpoint_sg.id]
    private_dns_enabled = true
    ip_address_type     = "ipv4"
    subnet_ids          = [aws_subnet.PrivateSubnet-1.id, aws_subnet.PrivateSubnet-2.id]
  }


# RT for private subnets
resource "aws_route_table" "PrivateRT" {
    vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table_association" "PrivateRTAssociation-1" {
    subnet_id      = aws_subnet.PrivateSubnet-1.id
    route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route_table_association" "PrivateRTAssociation-2" {
    subnet_id      = aws_subnet.PrivateSubnet-2.id
    route_table_id = aws_route_table.PrivateRT.id
}