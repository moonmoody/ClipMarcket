module "seoul_vpc" {
  source = "../vpc_module"
  pjt_name = var.seoul_pjt_name
  vpc_cidr = var.seoul_vpc_cidr

  providers = {
    aws = aws.seoul
  }
}
