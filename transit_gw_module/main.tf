# # TGW 생성
# resource "aws_ec2_transit_gateway" "tgw" {
#   amazon_side_asn = 64512
#   default_route_table_association = "enable"
#   default_route_table_propagation = "enable"

#   tags = {
#     Name = "${var.pjt_name}-tgw"
#   }
# }

# # TGW에 서울 VPC를 연결
# resource "aws_ec2_transit_gateway_vpc_attachment" "seoul_vpc_att" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = var.vpc_id
#   subnet_ids         = var.pri_sub_ids

#   tags = {
#     Name = "seoul-vpc-tgw-att"
#   }
# }


