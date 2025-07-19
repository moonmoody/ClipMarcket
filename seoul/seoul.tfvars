seoul_region   = "ap-northeast-2"
seoul_pjt_name = "seoul"
seoul_vpc_cidr = "10.10.0.0/16"
seoul_subnets = {
  "pub-a-1" = {
    cidr = "10.10.10.0/24"
    az   = "ap-northeast-2a"
  }
  "pub-c-2" = {
    cidr = "10.10.20.0/24"
    az   = "ap-northeast-2c"
  }
  "pri-a-3" = {
    cidr = "10.10.30.0/24"
    az   = "ap-northeast-2a"
  }
  "pri-c-4" = {
    cidr = "10.10.40.0/24"
    az   = "ap-northeast-2c"
  }
  "pri-a-5" = {
    cidr = "10.10.50.0/24"
    az   = "ap-northeast-2a"
  }
  "pri-c-6" = {
    cidr = "10.10.60.0/24"
    az   = "ap-northeast-2c"
  }
}
seoul_nat_gw_azs = {
  "ap-northeast-2a" = "a",
  "ap-northeast-2c" = "c"
}
seoul_ingress_rule_config = {
  proxy = {
    "mysql1" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "task" },
    "mysql2" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "lambda" },
  }
  bastion = null
  aurora = {
    "mysql1" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "proxy" },
    "mysql2" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "bastion" },
    "mysql3" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "lambda" },
  }
  lambda = null
  task = null
}

# 'source_sg_key'는 다른 보안그룹을 대상에 지정할 때 사용.
seoul_egress_rule_config = {
  proxy = {
    "mysql" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "aurora" },
  }
  bastion = {
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
    "mysql" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "aurora" },
  }
  aurora = {
    "mysql1" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "proxy" },
    "mysql2" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "bastion" },
    "mysql3" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "lambda" },
  }
  lambda = {
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
    "mysql1" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "proxy" },
    "mysql2" = { protocol = "tcp", from_port = "3306", to_port = "3306", cidr = "10.10.50.0/24" },
    "mysql3" = { protocol = "tcp", from_port = "3306", to_port = "3306", cidr = "10.10.60.0/24" },
  }
  task = {
    "mysql" = { protocol = "tcp", from_port = "3306", to_port = "3306", source_sg_key = "proxy" },
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" }
  }
}

# 가용영역 별로 auto scaling을 적용했기 때문에 숫자 설정에 유의
# 생각 한것 보다 절반으로 설정해야 함. (x2개가 생성되는 것이기 때문에)
seoul_pub_asg_config = {
  desired_capacity = 1      # 기본 인스턴스 수
  max_size         = 2
  min_size         = 1
}

