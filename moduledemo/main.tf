# Modules are a really key concept for the exam.
# In their simplest form, a modules is a folder that
# contains other terraform files.


provider "aws" {
  region     = "us-east-1"
}


resource "aws_instance" "myec2" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "Web Server"
  }
}

module "dbserver" {
  # Adding child module path here tells terraform to only set
  # up the resources in the child module.
  source = "./db/mysql"
  dbname = "mydbserver"
}

output "dbprivateip" {
  value = module.dbserver.privateip
}