# VPC Create
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.pjt_name}_gw"
  }
}

# Subnet Create
resource "aws_subnet" "sub" {
  for_each = var.subnets
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.pjt_name}_${each.key}_sub"
  }
}

locals {
  public_subnet_ids_by_az = {
    for name, subnet in var.subnets :
    subnet.az => aws_subnet.sub[name].id
    if startswith(name, "pub_")
  }
}


# Eip & Nat GW Create
resource "aws_eip" "eip" {
  for_each = toset(var.nat_gw_azs)
  domain   = "vpc"

  tags = {
    Name = "${var.pjt_name}_eip_${each.value}"
  }

  depends_on = [aws_internet_gateway.gw]
}

locals {
  eip_ids = {
    for az, eip in aws_eip.eip : az => eip.id
  }
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = local.eip_ids
  allocation_id = each.value
  subnet_id     = local.public_subnet_ids_by_az[each.key]

  tags = {
    Name = "${var.pjt_name}_nat_gw_${each.key}"
  }

  depends_on = [aws_internet_gateway.gw]
}


# # Route Table Create
# resource "aws_route_table" "pub_route_tb" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0"
#     gateway_id = aws_internet_gateway.gw.id
#   }
  
#   route {
#     cidr_block = "0.0.0.0"
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }

#   tags = {
#     Name = "${var.pjt_name}_pub_rt"
#   }
# }

# resource "aws_route_table" "pri_route_tb" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0"
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }

#   tags = {
#     Name = "${var.pjt_name}_pri_rt"
#   }
# }
