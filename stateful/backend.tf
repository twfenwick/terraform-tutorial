terraform {
  backend "s3" {
    bucket = "twf-terraform-cert-s3-backend"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
