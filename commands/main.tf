provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

# Tainting
resource "aws_vpc" "myvpc2" {
  cidr_block = "10.0.0.0/16"
}

# terraform import aws_vpc.vpcimport vpc-052adc36380873414
# resource "aws_vpc" "vpcimport" {
#   cidr_block = "10.0.0.0/16"
# }

