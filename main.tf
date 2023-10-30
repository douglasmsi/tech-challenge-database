provider "aws" {
  region = "us-east-1" # Substitua pela sua região
}

locals {
  vpc_name = "tech-challenge-vpc"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-public-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-private-*"]
  }
}



resource "aws_security_group" "tech-challenge-sg" {
  name_prefix = "tech-challenge-database-"
  subnet = data.aws_subnets.private.ids[0]

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }
}




resource "aws_db_instance" "tech-challenge-database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.6" # Substitua pela versão desejada do PostgreSQL
  instance_class       = "db.t2.micro" # Substitua pela classe de instância desejada
  username             = "db_username"
  password             = "db_password"
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.tech-challenge-sg.id]
  #db_subnet_group_name  = aws_db_subnet_group.tech-challenge-db-subnet-group.name
}


output "db_endpoint" {
  value = aws_db_instance.tech-challenge-database.endpoint
}
