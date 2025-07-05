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


output "ingress_rule_config" {
  value = var.seoul_ingress_rule_config
}


output "rule_lists" {
  value = module.seoul_instance.rule_lists
}
output "flat_rule_list" {
  value = module.seoul_instance.flat_rule_list
}
output "ingress_rules" {
  value = module.seoul_instance.ingress_rules
}
output "egress_rules" {
  value = module.seoul_instance.egress_rules
}

output "pri_sub_key_by_ids" {
  value = module.seoul_instance.pri_sub_key_by_ids
}

# output rules_only_key {
#   value       = module.seoul_instance.rules_only_key
# }

output valid_rules {
  value       = module.seoul_instance.valid_rules
}

output pub_subnet_ids {
  value       = module.seoul_instance.pub_subnet_ids
}

output all_sg_keys {
  value       = module.seoul_instance.all_sg_keys
}

