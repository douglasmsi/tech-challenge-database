provider "aws" {
  region = "us-east-1" # Substitua pela sua região
}

data "aws_vpc" "tech-challenge-vpc" {
  tags = {
    Name = "tech-challenge-vpc" # Substitua pelo nome da sua VPC
  }
}

variable "subnet_id" {}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["tech-challenge-vpc"]
  }
}

resource "aws_security_group" "subnet" {
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    type        = "ingress"
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

resource "aws_security_group_rule" "example" {
  type        = "ingress"
  from_port   = 5432 # Porta padrão do PostgreSQL
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # Restringir a faixa de IP conforme necessário
  security_group_id = aws_security_group.example.id # Substitua pelo ID do grupo de segurança do banco de dados
  #source_security_group_id = aws_security_group.cluster.id # Substitua pelo ID do grupo de segurança do cluster EKS
}

output "db_endpoint" {
  value = aws_db_instance.example.endpoint
}
