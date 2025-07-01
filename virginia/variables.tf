# 버지니아 리전
variable "virginia_region" {}
variable "virginia_pjt_name" {
  type        = string
  description = "프로젝트 이름"
}
variable "virginia_vpc_cidr" {
  type        = string
  description = "VPC에서 사용할 CIDR"
}
variable "virginia_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}
variable "virginia_nat_gw_azs" {
  type = map(any)
}
variable "virginia_ingress_rule_config" {
  description = "보안 그룹에 적용할 Ingress 규칙"
  type = object({
    # common = map(object({
    #   protocol  = string
    #   from_port = number
    #   to_port   = number
    #   cidr      = string
    # }))
    pub = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
    pri = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
  })
}
variable "virginia_egress_rule_config" {
  description = "보안 그룹에 적용할 Ingress 규칙"
  type = object({
    pub = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
    pri = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
  })
}
