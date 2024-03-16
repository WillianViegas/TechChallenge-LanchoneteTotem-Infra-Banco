terraform {
  backend "s3" {
    bucket = "terraform-tfstates-totem"
    key    = "totemLanchonete/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = var.regionDefault
}