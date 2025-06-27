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
