output ingress_rule_config {
  value       = var.ingress_rule_config
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

output ingress_rules {
  value       = local.ingress_rules
}
output egress_rules {
  value       = local.egress_rules
}


