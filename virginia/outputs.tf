output "vpc_local_pub_sub_info" {
  value       = module.virginia_vpc.local_pub_sub_info
  description = "local 확인"
}

output "vpc_eip_info" {
  value = module.virginia_vpc.eip_info
}

output "nat_gw_azs" {
  value = module.virginia_vpc.nat_gw_azs
}

output "pri_sub_info" {
  value = module.virginia_vpc.pri_sub_info
}

output "sub_key_by_ids" {
  description = "'pub_a_1' = 'subnet-0790b974529ff1ba7' 이런 형식의 데이터"
  value       = module.virginia_vpc.sub_key_by_ids
}