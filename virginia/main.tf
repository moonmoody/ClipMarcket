module "verginia_vpc" {
  source = "../vpc_module"
  pjt_name = var.virginia_pjt_name
  vpc_cidr = var.virginia_vpc_cidr

  providers = {
    aws = aws.virginia
  }
}
