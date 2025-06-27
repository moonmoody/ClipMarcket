seoul_region = "ap-northeast-2"
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
  "pri_a_5" = {
    cidr = "10.10.50.0/24"
    az   = "ap-northeast-2a"
  }
  "pri_c_6" = {
    cidr = "10.10.60.0/24"
    az   = "ap-northeast-2c"
  }
}



