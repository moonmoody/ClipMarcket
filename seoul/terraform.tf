# 테라폼 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

# 프로바이더
provider "aws" {
  alias  = "seoul"
  region = var.seoul_region
}
