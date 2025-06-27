virginia_region = "us-east-1"
virginia_pjt_name = "verginia"
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
virginia_nat_gw_azs = [
  "us-east-1a", 
  "us-east-1c"
]