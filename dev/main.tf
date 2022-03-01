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

