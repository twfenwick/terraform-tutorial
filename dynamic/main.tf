# Dyanmic blocks in Terraform is way to create
# reusable blocks of code that can be used to
# generate multiple resources or configurations
# based on a set of input values. This is
# particularly useful when you have a variable
# number of items to create or configure, such
# as security group rules, IAM policies, or any
# other resource that can have multiple instances.
#
# Don't overuse them as they can make your code
# harder to read and maintain.

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

variable "ingress_rules" {
  type = list(number)
  default = [25, 80, 443, 8080, 8443]
}

variable "egress_rules" {
  type = list(number)
  default = [443, 8443]
}

resource "aws_instance" "myec2db" {
  ami           = "ami-01a6e31ac994bbc09"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  tags = {
    Name = "Web Server"
  }
}

resource "aws_security_group" "web_traffic" {
  name = "Secure Server"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_rules
    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egress_rules
    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
