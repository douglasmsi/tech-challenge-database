provider "aws" {
  region = "us-east-1" # Substitua pela sua região
}

data "aws_vpc" "tech-challenge-vpc" {
  tags = {
    Name = "tech-challenge-vpc" # Substitua pelo nome da sua VPC
  }
}

data "aws_subnet" "selected" {
    vpc_id = data.aws_vpc.tech-challenge-vpc.id

}

resource "aws_security_group" "subnet" {
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    cidr_blocks = [data.aws_subnet.selected.cidr_block]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }
}




resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.6" # Substitua pela versão desejada do PostgreSQL
  instance_class       = "db.t2.micro" # Substitua pela classe de instância desejada
  username             = "db_username"
  password             = "db_password"
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
  vpc_security_group_ids = [data.aws_subnet.selected.id]
  #db_subnet_group_name  = aws_db_subnet_group.tech-challenge-db-subnet-group.name
}

resource "aws_security_group" "example" {
  name_prefix = "example-"
}

output "db_endpoint" {
  value = aws_db_instance.example.endpoint
}
