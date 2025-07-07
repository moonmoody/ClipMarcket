output ingress_rule_config {
  value       = var.ingress_rule_config
}


output rule_lists {
  value       = local.rule_lists
}
output flat_rule_list {
  value       = local.flat_rule_list
}
output ingress_rules {
  value       = local.ingress_rules
}
output egress_rules {
  value       = local.egress_rules
}

output valid_rules {
  value       = local.valid_rules
}
output pub_subnet_ids {
  value       = local.pub_subnet_ids
}
output all_sg_keys {
  value       = local.all_sg_keys
}
output pri_subnet_ids {
  value       = local.pri_subnet_ids
}


