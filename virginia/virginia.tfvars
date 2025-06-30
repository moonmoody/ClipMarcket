virginia_region   = "us-east-1"
virginia_pjt_name = "virginia"
virginia_vpc_cidr = "10.20.0.0/16"
virginia_subnets = {
  "pub_a_1" = {
    cidr = "10.20.10.0/24"
    az   = "us-east-1a"
  }
  "pub_c_2" = {
    cidr = "10.20.20.0/24"
    az   = "us-east-1c"
  }
  "pri_a_3" = {
    cidr = "10.20.30.0/24"
    az   = "us-east-1a"
  }
  "pri_c_4" = {
    cidr = "10.20.40.0/24"
    az   = "us-east-1c"
  }
}
virginia_nat_gw_azs = {
  "us-east-1a" = "a",
  "us-east-1c" = "c"
}
virginia_ingress_rule_config = {
  # common = {
  #   "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
  # }
  pub = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "http"  = { protocol = "tcp", from_port = "80",  to_port = "80",  cidr = "0.0.0.0/0" },
    "https" = { protocol = "tcp", from_port = "443", to_port = "443", cidr = "0.0.0.0/0" },
  }
  pri = {
    "icmp" = { protocol = "icmp", from_port = "-1", to_port = "-1", cidr = "0.0.0.0/0" }
    "ssh" = { protocol = "tcp", from_port = "22", to_port = "22", cidr = "0.0.0.0/0" },
  }
}