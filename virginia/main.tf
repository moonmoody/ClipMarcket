# data "terraform_remote_state" "global_outputs" {
#   backend = "s3"
#   config = {
#     bucket = "clipmarket-terraform-state" # 상태 파일이 저장된 S3 버킷
#     key    = "global/terraform.tfstate"  # global 환경의 상태 파일 경로
#     region = "ap-northeast-2"            # S3 버킷이 있는 리전
#   }
# }

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
  source                                = "../instance_module"
  pjt_name                              = var.virginia_pjt_name
  vpc_sub_key_by_ids                    = module.virginia_vpc.sub_key_by_ids
  vpc_id                                = module.virginia_vpc.vpc_id
  nat_gw                                = module.virginia_vpc.nat_gw
  pri_sub34_ids_by_az                   = module.virginia_vpc.pri_sub34_ids_by_az
  subnets                               = var.virginia_subnets
  ingress_rule_config                   = var.virginia_ingress_rule_config
  egress_rule_config                    = var.virginia_egress_rule_config
  # ssm_instance_profile_name_from_global = data.terraform_remote_state.global_outputs.outputs.ssm_instance_profile_name
  ssm_instance_profile_name_from_global = "bastion-ssm-instance-profile"
  pub_asg_config                        = var.virginia_pub_asg_config

  providers = {
    aws = aws.virginia
  }
}

