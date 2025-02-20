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
}

resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
}

variable "mytuple" {
  type = tuple([string, number, string])
  default = (["cat", 1, "dog"])
}

variable "myobject" {
  type = object({name = string, port = list(number)})
  default = {
    name = "Tim"
    port = [22, 25, 80]
  }
}