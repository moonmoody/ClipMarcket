locals {
  pub_sub_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if startswith(key, "pub_")
  }
  pri_sub_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if startswith(key, "pri_")
  }

  # AZ별로 1개씩만 고르기 (예: 2a, 2c 중복 제거)
  pub_subnet_ids_by_az = {
    for az, pair in {
      for key, id in local.pub_sub_key_by_ids : var.subnets[key].az => {
        key = key
        id  = id
      }
    } : az => pair.id
  }

  pub_subnet_ids = values(local.pub_subnet_ids_by_az)  # ALB에 넣을 list(string)

  pri_subnet_ids_by_az = {
    for az, pair in {
      for key, id in local.pri_sub_key_by_ids : var.subnets[key].az => {
        key = key
        id  = id
      }
    } : az => pair.id
  }

  pri_subnet_ids = values(local.pri_subnet_ids_by_az)  # ALB에 넣을 list(string)
}

locals {
  # null 값인 데이터 걸러내기
  valid_rules = {
    for sg_key, rules in var.ingress_rule_config : sg_key => rules if rules != null
  }

  # map은 중첩 for문이 불가능 하므로 [ [ ] ] 형태로 변환
  # [ [ {pub 규칙1}, {pub 규칙2} ], [ {pri 규칙1}, {pri 규칙2} ] ]
  rule_lists = [
    for sg_key, rules in local.valid_rules : [
      for rule_key, rule in rules : {
        sg_key    = sg_key
        rule_key  = rule_key
        protocol  = rule.protocol
        from_port = rule.from_port
        to_port   = rule.to_port
        cidr      = rule.cidr
      }
    ]
  ]

  # 중첩 리스트를 단일 리스트 구조로 변환
  flat_rule_list = flatten(local.rule_lists)

  ingress_rules = {
    # [{데이터1}, {데이터2}, {데이터3}...] 을 item 에 setting
    for item in local.flat_rule_list :
    # 키 생성 (예시 "pub-http")
    "${item.sg_key}-${item.rule_key}" => {
      sg_id     = aws_security_group.sg[item.sg_key].id
      protocol  = item.protocol
      from_port = item.from_port
      to_port   = item.to_port
      cidr_ipv4 = item.cidr
    }
  }
}


# 가장 최신의 Amazon Linux 2 AMI를 동적으로 찾아오기
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"] # AWS가 제공하는 공식 AMI

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 현재 사용 중인 리전 데이터 가져오기
data "aws_region" "current" {}

# 가장 최신의 Amazon Ubuntu AMI를 동적으로 찾아오기
# data "aws_ami" "latest_ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# 프록시 서버 키페어는 없어도 무방함
resource "aws_key_pair" "pub_key" {
  key_name   = "pub_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCA1wGQwHj1YsyndGjKZzDWU/lbwhiisVg11U7o3XFkjoV57M207pMjVdk0cGdismABfpq1amJrZ6P+QSzKqu+FHdebZar8C+oe1iwGgJwol5+IPt1vTmryYG+1XoAvmJNZjzY56WlmIZLYmG+VybHGd/OItO6hES/KjHP5FRnTptO1v77nb/EXUfA/WyJPr47Fb9y70jxSt+/0T4Hv397ZLVpenTWN59O8VI5ekjMyWIBwkxL9liFq2EJyTgJKy6dL3VBAQnDh4Ouh2oflD6pwbSD3HLwbDFHh/ChHi97TZ6mvO5bj3EzBP5Nwg5tSSjUosI89GDdnuu+4vv/ubRjn rsa-key-20250629"
}


# Security Group Create
resource "aws_security_group" "sg" {
  for_each = data.aws_region.current.name == "ap-northeast-2" ? toset(["pub", "pri_1", "pri_2"]) : toset(["pub", "pri"])
  name        = "sg_${each.key}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.pjt_name}_sg_${each.key}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
  for_each = local.ingress_rules
  security_group_id = each.value.sg_id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
}

resource "aws_vpc_security_group_egress_rule" "sg_egress" {
  for_each = aws_security_group.sg 
  security_group_id = each.value.id 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# Instance Create
resource "aws_instance" "pub_instance" {
  for_each = local.pub_sub_key_by_ids
  ami      = data.aws_ami.latest_linux.id
  # ami                         = "ami-000ec6c25978d5999"         # 버지니아 ami
  # ami                         = "ami-0daee08993156ca1a"        # 서울 ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = each.value
  vpc_security_group_ids      = [aws_security_group.sg["pub"].id]
  key_name                    = "pub_key"

  tags = {
    Name = "${var.pjt_name}_pub_${regex("_([a-z])_", each.key)[0]}"
  }

  depends_on = [var.nat_gw]
}

# Seoul 리전에서만 생성.
resource "aws_instance" "pri_instance" {
  for_each = data.aws_region.current.name == "ap-northeast-2" ? local.pri_sub_key_by_ids : {}
  ami      = data.aws_ami.latest_linux.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  subnet_id                   = each.value
  vpc_security_group_ids      = data.aws_region.current.name == "ap-northeast-2" ? [aws_security_group.sg["pri_1"].id] : [aws_security_group.sg["pri"].id]

  tags = {
    Name = "${var.pjt_name}_pri_${regex("_([a-z])_", each.key)[0]}"
  }

  depends_on = [var.nat_gw]
}

# Create Target Group
resource "aws_lb_target_group" "pub_tg" {
  name     = "web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


# Attachment Target Group 
resource "aws_lb_target_group_attachment" "pub_tg_web_att" {
  for_each = aws_instance.pub_instance
  target_group_arn = aws_lb_target_group.pub_tg.arn
  target_id        = each.value.id
  port             = 80
}


# Create Listener
resource "aws_lb_listener" "pub_web_alb_listener" {
  load_balancer_arn = aws_lb.pub_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pub_tg.arn
  }
}

# Create alb for Public Subnet
resource "aws_lb" "pub_alb" {
  name               = "${var.pjt_name}-pub-alb"
  internal           = false                                
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pub_alb_sg.id]
  subnets            = local.pub_subnet_ids                 

  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}-pub-alb"
  }
}

# ALB Security Group
resource "aws_security_group" "pub_alb_sg" {
  name        = "${var.pjt_name}-pub-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pjt_name}-pub-alb-sg"
  }
}

# Private Load Balancer
# Seoul 리전에서만 생성.
resource "aws_lb_target_group" "pri_tg" {
  count = data.aws_region.current.name == "ap-northeast-2" ? 1 : 0
  name     = "pri-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "pri_tg_att" {
  for_each = data.aws_region.current.name == "ap-northeast-2" ? aws_instance.pri_instance : {}
  target_group_arn = aws_lb_target_group.pri_tg[0].arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "pri_alb_listener" {
  count = data.aws_region.current.name == "ap-northeast-2" ? 1 : 0
  load_balancer_arn = aws_lb.pri_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pri_tg[0].arn
  }
}

resource "aws_lb" "pri_alb" {
  count = data.aws_region.current.name == "ap-northeast-2" ? 1 : 0
  name               = "${var.pjt_name}-pri-alb"
  internal           = false                                
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pri_alb_sg[0].id]
  subnets            = local.pri_subnet_ids                 

  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}-pri-alb"
  }
}

resource "aws_security_group" "pri_alb_sg" {
  count = data.aws_region.current.name == "ap-northeast-2" ? 1 : 0
  name        = "${var.pjt_name}-pri-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pjt_name}-pri-alb-sg"
  }
}

