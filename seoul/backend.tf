terraform {
  backend "s3" {
    bucket         = "clipmarket-terraform-state"
    key            = "seoul/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
