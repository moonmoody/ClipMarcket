module "verginia_vpc" {
  source     = "../vpc_module"
  pjt_name   = var.virginia_pjt_name
  vpc_cidr   = var.virginia_vpc_cidr
  subnets    = var.virginia_subnets
  nat_gw_azs = var.virginia_nat_gw_azs

  providers = {
    aws = aws.virginia
  }
}
