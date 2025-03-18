provider "aws" {
  region     = "us-east-1"
}


resource "aws_instance" "myec2" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "Web Server"
  }

  # This ensures the correct order of resource creation
  # Here, DB Server will be created first
  depends_on = [aws_instance.myec2db]
}

resource "aws_instance" "myec2db" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Server"
  }
}

# Query any resource in AWS with "data sources"
# API request only (doesn't setup anything)
data "aws_instance" "dbsearch" {
  filter {
    name = "tag:Name"
    values = ["DB Server"]
  }
  # This part not in the course, got from SO:
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

output "dbservers" {
  # Check terraform documentation for all possible attributes.
  # Or autocomplete/suggestive typing.
  value = data.aws_instance.dbsearch.availability_zone
}

# Be aware of built-in functions for the exam. Don't need to
# know all of them, but point is to be aware of them.

# file(path)
# element(list, index)
# values(map)
# flatten(list)
# Just try a few of them out, don't stress out over all of them

# Terraform Versioning
# No link in the course.
# =
# !=

# Overall - couple links are missing when he says he'll
# include them in the course comments.

