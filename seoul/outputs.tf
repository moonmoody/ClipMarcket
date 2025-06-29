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

output "vpc_sub_ids" {
  description = "생성된 서브넷 ID"
  value       = module.seoul_vpc.sub_ids
}