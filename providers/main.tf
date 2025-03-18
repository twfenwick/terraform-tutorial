terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Can set version of provider here
  version = "2.0"
}


provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

resource "aws_vpc" "vavpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "orgvpc" {
  cidr_block = "10.0.0.0/16"
  provider   = aws.oregon
}