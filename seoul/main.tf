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

module "seoul_instance" {
  source      = "../instance_module"
  pjt_name    = var.seoul_pjt_name
  vpc_sub_ids = module.seoul_vpc.sub_ids
  vpc_id      = module.seoul_vpc.vpc_id
  nat_gw      = module.seoul_vpc.nat_gw
  sub_ids     = values(module.seoul_vpc.sub_ids)
  subnets     = var.seoul_subnets 

  providers = {
    aws = aws.seoul
  }
}
