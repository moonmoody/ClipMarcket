variable "pjt_name" {
  type        = string
  description = "프로젝트 명"
}

variable "vpc_sub_key_by_ids" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "nat_gw" {
  type = map(any)
}

variable "subnets" {
  type = map(object({
    cidr = string
    az = string
  }))
}

variable "ingress_rule_config" {
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
variable "egress_rule_config" {
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

variable "ssm_instance_profile_name_from_global" {
  description = "iam 값"
  type = string
}

variable "pub_asg_config" {
  description = "Auto Scaling Group 설정 값"
  type = object({
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
}

variable pri_sub34_ids_by_az {
  description = "ALB에 적용될 private subnet 3번 4번 데이터"
  type        = map
}

