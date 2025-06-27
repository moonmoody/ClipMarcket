# 서울 리전
variable "seoul_region" {}
variable "seoul_pjt_name" {
  type        = string
  description = "프로젝트 이름"
}
variable "seoul_vpc_cidr" {
  type = string
  description = "VPC에서 사용할 CIDR"
}
variable "seoul_subnets" {
   type = map(object({
    cidr = string
    az   = string
  }))
}
