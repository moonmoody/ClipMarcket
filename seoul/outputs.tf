output "vpc_eip_info" {
  value = module.seoul_vpc.eip_info
}

output "nat_gw_azs" {
  value = module.seoul_vpc.nat_gw_azs
}

output "pub_sub_info" {
  value       = module.seoul_vpc.pub_sub_info
  description = "local 확인"
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


output pub_subnet_ids {
  value       = module.seoul_instance.pub_subnet_ids
}

output all_sg_keys {
  value       = module.seoul_instance.all_sg_keys
}

output subnets {
  value       = module.seoul_vpc.subnets
}


output pri_subnet_ids {
  value       = module.seoul_instance.pri_subnet_ids
}
