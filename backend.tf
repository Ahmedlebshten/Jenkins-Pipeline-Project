terraform {
  backend "s3" {
    bucket  = "jenkins-terraform-backend-9904"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

