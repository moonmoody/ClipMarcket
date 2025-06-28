module "seoul_vpc" {
  source     = "../vpc_module"
  pjt_name   = var.seoul_pjt_name
  vpc_cidr   = var.seoul_vpc_cidr
  subnets    = var.seoul_subnets
  nat_gw_azs = var.seoul_nat_gw_azs

  providers = {
    aws = aws.seoul
  }
}
