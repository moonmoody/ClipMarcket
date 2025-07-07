# 단순 정보 확인
output "eip_info" {
  value = aws_eip.eip
}

output "nat_gw_azs" {
  value = var.nat_gw_azs
}

output "pri_sub34_ids_by_az" {
  value = local.pri_subnet_ids_by_az
}

output "pub_sub_info" {
  value       = local.pub_subnet_ids_by_az
  description = "local 확인"
}

# 실제 사용할 data
output "sub_key_by_ids" {
  # type = map(object)
  description = "'pub_a_1' = 'subnet-0790b974529ff1ba7' 이런 형식의 데이터"
  value = {
    for key, subnet in aws_subnet.sub : key => subnet.id
  }
}

output "vpc_id" {
  # type = string
  value = aws_vpc.vpc.id
}

output "nat_gw" {
  value = aws_nat_gateway.nat_gw
}

output "pri_sub_ids" {
  # type = map(object)
  description = "private subnet id가 list 형태로 담긴 데이터"
  value = [
    for key, subnet in aws_subnet.sub : subnet.id if startswith(key, "pri_")
  ]
}

output subnets {
  value       = var.subnets
}
