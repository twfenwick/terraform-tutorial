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

variable "vpcname" {
  type = string
  default = "myvpc"
}

variable "sshport" {
  type = number
  default = 22
}

variable "enabled" {
  default = true
}

variable "mylist" {
  type = list(string)
  default = ["Value1", "Value2"]
}

variable "mymap" {
  type = map(string)
  default = {
    key1="val1",
    key2="val2"
  }
}

variable "inputname" {
  type = string
  description = "set name of vpc"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.inputname
  }
}

output "vpcid" {
  # value = type.name.attribute:
  value = aws_vpc.myvpc.id
}