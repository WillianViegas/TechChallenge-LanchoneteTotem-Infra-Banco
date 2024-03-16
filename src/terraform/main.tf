resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Specify the CIDR block for your VPC
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24" # Specify the CIDR block for subnet A
  availability_zone = "us-east-1a"  # Specify the desired Availability Zone
  tags = {
    Name = "subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24" # Specify the CIDR block for subnet B
  availability_zone = "us-east-1b"  # Specify the desired Availability Zone
  tags = {
    Name = "subnet-b"
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group_v2" {
  name       = "my-db-subnet-group-v2"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id] # Specify the subnet IDs in your VPC
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb-sg"
  description = "Security group for DocumentDB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
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

resource "aws_docdb_cluster_instance" "docdb_instance" {
  cluster_identifier = aws_docdb_cluster.aws_docdb_cluster.id
  instance_class     = "db.t3.medium"
  engine             = "docdb"
}

resource "aws_docdb_cluster" "aws_docdb_cluster" {
  cluster_identifier        = "aws-docdb-cluster-v2"
  availability_zones        = ["us-east-1a", "us-east-1b"]
  master_username           = var.databaseUser
  master_password           = var.databasePass
  db_subnet_group_name      = aws_db_subnet_group.my_db_subnet_group_v2.name
  vpc_security_group_ids    = [aws_security_group.docdb_sg.id]
  backup_retention_period   = 7
  preferred_backup_window   = "07:00-09:00"
  apply_immediately         = true
  skip_final_snapshot   = true
}

