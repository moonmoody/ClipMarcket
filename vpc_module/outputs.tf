# 단순 정보 확인
output "local_pub_sub_info" {
  value       = local.pub_subnet_ids_by_az
  description = "local 확인"
}

output "eip_info" {
  value = aws_eip.eip
}

output "nat_gw_azs" {
  value = var.nat_gw_azs
}

output "pri_sub_info" {
  value = local.pri_subnet_ids_by_az
}



# 실제 사용할 data
output "sub_ids" {
  description = "생성된 서브넷 ID"
  value = {
    for key, subnet in aws_subnet.sub : key => subnet.id
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "nat_gw" {
  value = aws_nat_gateway.nat_gw
}

