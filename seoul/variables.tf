# 서울 리전
variable "seoul_region" {}

variable "seoul_pjt_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "seoul_vpc_cidr" {
  type        = string
  description = "VPC에서 사용할 CIDR"
}

variable "seoul_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "seoul_nat_gw_azs" {
  type = map(any)
}

variable "seoul_ingress_rule_config" {
  description = "보안 그룹에 적용할 Ingress 규칙"
  type = object({
    pub = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
    proxy = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
    bastion = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
    aurora = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
  })
}
variable "seoul_egress_rule_config" {
  description = "보안 그룹에 적용할 egress 규칙"
  type = object({
    pub = map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    }))
    proxy = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
    bastion = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
    aurora = optional(map(object({
      protocol  = string
      from_port = number
      to_port   = number
      cidr      = string
    })))
  })
}

variable "seoul_pub_asg_config" {
  description = "Auto Scaling Group 설정 값"
  type = object({
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
}


