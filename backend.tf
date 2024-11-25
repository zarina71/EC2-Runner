terraform {
  backend "s3" {
    bucket         = "rezterraformremote"
    region         = "eu-west-2"
    key            = "Github-Runner-TF/terraform.tfstate"
    encrypt        = true
  }
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}