module "virginia_vpc" {
  source     = "../vpc_module"
  pjt_name   = var.virginia_pjt_name
  vpc_cidr   = var.virginia_vpc_cidr
  subnets    = var.virginia_subnets
  nat_gw_azs = var.virginia_nat_gw_azs

  providers = {
    aws = aws.virginia
  }
}

module "virginia_instance" {
  source      = "../instance_module"
  pjt_name    = var.virginia_pjt_name
  vpc_sub_ids = module.virginia_vpc.sub_ids
  vpc_id      = module.virginia_vpc.vpc_id
  nat_gw      = module.virginia_vpc.nat_gw
  subnets     = var.virginia_subnets 

  providers = {
    aws = aws.virginia
  }
}
