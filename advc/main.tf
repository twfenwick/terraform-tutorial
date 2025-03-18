provider "aws" {
  region = "us-east-1"
}

# Using environment variables:
# export TF_VAR_vpcname=envvpc
# terraform will get this var and use it here as an input.
variable "vpcname" {
  type    = string
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpcname
  }
}

# Can also input variables from cmd line:
# terraform plan -var "vpcname"=cliname

# As well as from a file:
# terraform plan -var-file="myvars.tfvars"


