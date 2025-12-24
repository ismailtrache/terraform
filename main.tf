terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "ca-central-1"
}


resource "aws_instance" "monserveur" {
  ami           = "ami-085f043560da76e08"
  instance_type = "t3.micro"

  tags = {
    Name = "serveurInstance"
  }
}

resource "aws_vpc" "vpc_toronto_test" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc_toronto_test"
  }
}

resource "aws_s3_bucket" "bucket_test_terraform_123456" {
  bucket = "bucket-test-terraform-123456"

  tags = {
    Name        = "bucket_test_terraform_123456"
    Environment = "Dev"
  }
}


resource "aws_db_instance" "db_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"

  db_name              = "mydb"
  username             = "admin"
  password             = "password1234"

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  tags = {
    Name = "mydb-instance"
  }
}


