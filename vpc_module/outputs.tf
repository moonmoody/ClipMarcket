output local_pub_sub_info {
  value       = local.pub_subnet_ids_by_az
  description = "local 확인"
}

output eip_info {
  value       = aws_eip.eip
}

output nat_gw_azs {
  value       = var.nat_gw_azs
}

output pri_sub_info {
  value       = local.pri_subnet_ids_by_az
}
