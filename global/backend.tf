terraform {
  backend "s3" {
    bucket         = "clipmarket-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
