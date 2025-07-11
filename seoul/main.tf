# data "terraform_remote_state" "global_outputs" {
#   backend = "s3" # global 환경이 사용하는 백엔드 타입 (예: s3)

#   config = {
#     # global 환경의 상태 파일 정보를 정확히 입력합니다.
#     bucket = "my-company-tfstate-bucket" # 상태 파일이 저장된 S3 버킷
#     key    = "global/terraform.tfstate"  # global 환경의 상태 파일 경로
#     region = "ap-northeast-2"            # S3 버킷이 있는 리전
#   }
# }

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
  source                                = "../instance_module"
  pjt_name                              = var.seoul_pjt_name
  vpc_sub_key_by_ids                    = module.seoul_vpc.sub_key_by_ids
  vpc_id                                = module.seoul_vpc.vpc_id
  nat_gw                                = module.seoul_vpc.nat_gw
  pri_sub34_ids_by_az                   = module.seoul_vpc.pri_sub34_ids_by_az
  subnets                               = var.seoul_subnets
  ingress_rule_config                   = var.seoul_ingress_rule_config
  egress_rule_config                    = var.seoul_egress_rule_config
  # ssm_instance_profile_name_from_global = data.terraform_remote_state.global_outputs.outputs.ssm_instance_profile_name
  ssm_instance_profile_name_from_global = "bastion-ssm-instance-profile"
  pub_asg_config                        = var.seoul_pub_asg_config

  providers = {
    aws = aws.seoul
  }
}
