virginia_region   = "us-east-1"
virginia_pjt_name = "virginia"
virginia_vpc_cidr = "10.20.0.0/16"
virginia_subnets = {
  "pub-a-1" = {
    cidr = "10.20.10.0/24"
    az   = "us-east-1a"
  }
  "pub-c-2" = {
    cidr = "10.20.20.0/24"
    az   = "us-east-1c"
  }
  "pri-a-3" = {
    cidr = "10.20.30.0/24"
    az   = "us-east-1a"
  }
  "pri-c-4" = {
    cidr = "10.20.40.0/24"
    az   = "us-east-1c"
  }
}
virginia_nat_gw_azs = {
  "us-east-1a" = "a",
  "us-east-1c" = "c"
}
virginia_ingress_rule_config = {
  pub = {
    "http"  = { protocol = "tcp", from_port = "80", to_port = "80", cidr = "0.0.0.0/0" },
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
    "ssh"   = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
  bastion = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
  }
  aurora = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "ssh"  = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
}
virginia_egress_rule_config = {
  pub = {
    "all" = { protocol = "all", from_port = null, to_port = null, cidr = "0.0.0.0/0" }
  }
  bastion = {
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
    "dns" = { protocol = "udp", from_port = "53", to_port = "53", cidr = "0.0.0.0/0" }
  }
  aurora = {
    "all" = { protocol = "all", from_port = null, to_port = null, cidr = "0.0.0.0/0" }
  }
}

# 가용영역 별로 auto scaling을 적용했기 때문에 숫자 설정에 유의
# 생각 한것 보다 절반으로 설정해야 함. (x2개가 생성되는 것이기 때문에)
virginia_pub_asg_config = {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1
}