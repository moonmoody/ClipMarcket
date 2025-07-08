
# 현재 사용 중인 리전 데이터 가져오기
data "aws_region" "current" {}

locals {
  eip_ids = {
    for az, eip in aws_eip.eip : az => eip.id
  }
  pub_subnet_ids_by_az = {
    for name, subnet in var.subnets : subnet.az => aws_subnet.sub[name].id if startswith(name, "pub-")
  }
  pri_subnet_ids_by_az = {
    for name, subnet in var.subnets : subnet.az => aws_subnet.sub[name].id if data.aws_region.current.id == "ap-northeast-2" ? contains(["pri-a-3", "pri-c-4"], name) : startswith(name, "pri-a-3")
  }
}

# VPC Create
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pjt_name}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.pjt_name}-gw"
  }
}

# Subnet Create
resource "aws_subnet" "sub" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.pjt_name}-${each.key}-sub"
  }
}

# Eip & Nat GW Create
resource "aws_eip" "eip" {
  for_each = var.nat_gw_azs
  domain   = "vpc"

  tags = {
    Name = "${var.pjt_name}-eip-${each.value}"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gw" {
  for_each      = local.eip_ids
  allocation_id = each.value
  subnet_id     = local.pub_subnet_ids_by_az[each.key]

  tags = {
    Name = "${var.pjt_name}-nat-gw-${regexall("[a-z]$", each.key)[0]}"
  }

  depends_on = [aws_internet_gateway.gw]
}


# Route Table Create
resource "aws_route_table" "pub_route_tb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.pjt_name}-pub-rt"
  }
}

resource "aws_route_table" "pri_route_tb" {
  # virginia에서는 a 가용영역에서 사용할 것만 생성 되도록...
  for_each = data.aws_region.current.id == "ap-northeast-2" ? var.nat_gw_azs : { for az, val  in var.nat_gw_azs : az => val if val == "a" }

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[each.key].id
  }

  tags = {
    Name = "${var.pjt_name}-pri-${each.value}-rt"
  }
}

resource "aws_route_table_association" "pub_rt_ass" {
  for_each       = local.pub_subnet_ids_by_az
  subnet_id      = each.value
  route_table_id = aws_route_table.pub_route_tb.id
}

resource "aws_route_table_association" "pri_rt_ass" {
  for_each       = local.pri_subnet_ids_by_az
  subnet_id      = each.value
  route_table_id = aws_route_table.pri_route_tb[each.key].id
}