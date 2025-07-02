seoul_region   = "ap-northeast-2"
seoul_pjt_name = "seoul"
seoul_vpc_cidr = "10.10.0.0/16"
seoul_subnets = {
  "pub_a_1" = {
    cidr = "10.10.10.0/24"
    az   = "ap-northeast-2a"
  }
  "pub_c_2" = {
    cidr = "10.10.20.0/24"
    az   = "ap-northeast-2c"
  }
  "pri_a_3" = {
    cidr = "10.10.30.0/24"
    az   = "ap-northeast-2a"
  }
  "pri_c_4" = {
    cidr = "10.10.40.0/24"
    az   = "ap-northeast-2c"
  }
}
seoul_nat_gw_azs = {
  "ap-northeast-2a" = "a",
  "ap-northeast-2c" = "c"
}
seoul_ingress_rule_config = {
  pub = {
    "icmp"  = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "http"  = { protocol = "tcp", from_port = "80", to_port = "80", cidr = "0.0.0.0/0" },
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
    "ssh"   = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
  proxy = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "ssh"  = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
  bastion = {
    # "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "ssh" = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
  aurora = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "ssh"  = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
}
seoul_egress_rule_config = {
  pub = {
    "all" = { protocol = "-1", from_port = "0", to_port = "0", cidr = "0.0.0.0/0" }
  }
  proxy = {
    "all" = { protocol = "-1", from_port = "0", to_port = "0", cidr = "0.0.0.0/0" }
  }
  bastion = {
    "all" = { protocol = "-1", from_port = "0", to_port = "0", cidr = "0.0.0.0/0" }
  }
  aurora = {
    "all" = { protocol = "-1", from_port = "0", to_port = "0", cidr = "0.0.0.0/0" }
  }
}

