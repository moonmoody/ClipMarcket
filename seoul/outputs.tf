output "vpc_local_pub_sub_info" {
  value       = module.seoul_vpc.local_pub_sub_info
  description = "local 확인"
}

output "vpc_eip_info" {
  value = module.seoul_vpc.eip_info
}

output "nat_gw_azs" {
  value = module.seoul_vpc.nat_gw_azs
}

output "pri_sub_info" {
  value = module.seoul_vpc.pri_sub_info
}