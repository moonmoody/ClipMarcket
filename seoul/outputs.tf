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

output "vpc_sub_key_by_ids" {
  description = "'pub_a_1' = 'subnet-0790b974529ff1ba7' 이런 형식의 데이터"
  value       = module.seoul_vpc.sub_key_by_ids
}

output "vpc_nat_gw" {
  value = module.seoul_vpc.nat_gw
}

output rules_by_tier {
  value       = module.seoul_instance.rules_by_tier
}
output all_ingress_rules {
  value       = module.seoul_instance.all_ingress_rules
}
# output all_a {
#   value       = module.seoul_instance.all_a
# }