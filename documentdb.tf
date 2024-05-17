variable "aws-region" {
  type        = string  
  description = "Região da AWS"
  default     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "techchallengestate-g27"
    key            = "terraform-documentdb/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }

  required_providers {
    
    random = {
      version = "~> 3.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "vpcTechChallenge" {
  tags = {
    Name = "Default VPC to Tech Challenge"
  }
}

resource "aws_default_subnet" "subnetTechChallenge" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a to Tech Challenge"
  }
}

resource "aws_default_subnet" "subnetTechChallenge2" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for us-east-1b to Tech Challenge"
  }
}

resource "random_string" "username" {
  length  = 16
  special = false
  upper   = true
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "/@\" "
}

locals {
  encoded_password = urlencode(random_string.password.result)
}

resource "aws_secretsmanager_secret" "document_db_credentials" {
  name        = "documentdbcredentials"
}

resource "aws_secretsmanager_secret_version" "document_db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.document_db_credentials.id
  secret_string = jsonencode({
    username = random_string.username.result
    password = random_string.password.result
    endpoint = aws_docdb_cluster_instance.cluster_instance[0].endpoint
    port = aws_docdb_cluster_instance.cluster_instance[0].port
    url = "mongodb://${random_string.username.result}:${local.encoded_password}@${aws_docdb_cluster_instance.cluster_instance[0].endpoint}:${aws_docdb_cluster_instance.cluster_instance[0].port}/app"
  })
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "techchallenge-cluster"
  engine                  = "docdb"
  master_username         = random_string.username.result
  master_password         = random_string.password.result
}

resource "aws_docdb_cluster_instance" "cluster_instance" {
  count              = 1
  identifier         = "techchallenge-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}