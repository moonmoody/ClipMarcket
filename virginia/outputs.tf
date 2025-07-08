output "vpc_eip_info" {
  value = module.virginia_vpc.eip_info
}

output "nat_gw_azs" {
  value = module.virginia_vpc.nat_gw_azs
}


output "pub_sub_info" {
  value       = module.virginia_vpc.pub_sub_info
  description = "local 확인"
}

output "sub_key_by_ids" {
  description = "'pub_a_1' = 'subnet-0790b974529ff1ba7' 이런 형식의 데이터"
  value       = module.virginia_vpc.sub_key_by_ids
}
output "ingress_rule_config" {
  value = var.virginia_ingress_rule_config
}



output all_sg_keys {
  value       = module.virginia_instance.all_sg_keys
}
