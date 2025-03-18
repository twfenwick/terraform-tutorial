resource "aws_instance" "myec2db" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Server"
  }
}
