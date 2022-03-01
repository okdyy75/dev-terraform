############################################################
### プロバイダー 
############################################################
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
  backend "s3" {
    bucket = "y-oka-tfstate"
    region = "ap-northeast-1"
    key    = "dev-terraform.tfstate"
  }
}

provider "aws" {
  profile = "dev-user"
  region  = "ap-northeast-1"
}

############################################################
### 変数定義 
############################################################
variable "env" {
  description = "実行環境"
  type        = string
}
variable "y_oka_domain" {
  description = "y-okaドメイン"
  type        = string
}

############################################################
### IAM 
############################################################
resource "aws_iam_role" "y-oka-apprunner-role" {
  name = "dev-y-oka-apprunner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  ]
}

############################################################
### AppRunner
############################################################
resource "time_sleep" "wait-create-y-oka-apprunner-role" {
  create_duration = "5s"
  depends_on = [
    aws_iam_role.y-oka-apprunner-role
  ]
}

resource "aws_apprunner_service" "y-oka-apprunner" {
  service_name = "dev-y-oka-apprunner"
  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.y-oka-apprunner-role.arn
    }
    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "162699281520.dkr.ecr.ap-northeast-1.amazonaws.com/y-oka/nginx:latest"
      image_repository_type = "ECR"
    }
  }
  depends_on = [
    time_sleep.wait-create-y-oka-apprunner-role
  ]
}

############################################################
### Route 53 
############################################################
resource "aws_apprunner_custom_domain_association" "y-oka-apprunner-custom-domain" {
  service_arn          = aws_apprunner_service.y-oka-apprunner.arn
  domain_name          = var.y_oka_domain
  enable_www_subdomain = true
}

# DNSプロバイダー（自分の場合はgoogleドメイン）に証明書の検証を登録する
output "y-oka-apprunner-custom-domain-certificate-validation-records" {
  value = aws_apprunner_custom_domain_association.y-oka-apprunner-custom-domain.certificate_validation_records
}

# DNSプロバイダー（自分の場合はgoogleドメイン）にCNAMEを登録する
output "y-oka-apprunner-custom-domain-dns-target" {
  value = "${var.y_oka_domain} = ${aws_apprunner_custom_domain_association.y-oka-apprunner-custom-domain.dns_target}"
}