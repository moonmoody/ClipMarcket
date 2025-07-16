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

locals {
  pub_sub_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if startswith(key, "pub-")
  }
  pri_sub34_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if data.aws_region.current.id == "ap-northeast-2" ? contains(["pri-a-3", "pri-c-4"], key) : startswith(key, "pri-a-3")
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

  pri_subnet_ids = values(var.pri_sub34_ids_by_az)  # ALB에 넣을 list(string)
}

# locals for security group keys
locals {
  all_sg_keys = toset(concat(
    keys(var.ingress_rule_config),
    keys(var.egress_rule_config)
  ))

  # Ingress 규칙을 aws_security_group_rule 리소스에 맞게 평탄화 (null 처리 보완)
  ingress_rules = flatten([
    for sg_key, rules in var.ingress_rule_config : [
      for rule_key, rule in (rules != null ? rules : {}) : {
        sg_key    = sg_key
        rule_key  = rule_key
        protocol  = rule.protocol
        from_port = rule.from_port
        to_port   = rule.to_port
        cidr_blocks = try(rule.cidr, null) != null ? [rule.cidr] : null
        source_security_group_key = try(rule.source_sg_key, null)
      }
    ]
  ])

  # Egress 규칙도 동일하게 수정
  egress_rules = flatten([
    for sg_key, rules in var.egress_rule_config : [
      for rule_key, rule in (rules != null ? rules : {}) : {
        sg_key    = sg_key
        rule_key  = rule_key
        protocol  = rule.protocol
        from_port = rule.from_port
        to_port   = rule.to_port
        cidr_blocks = try(rule.cidr, null) != null ? [rule.cidr] : null
        source_security_group_key = try(rule.source_sg_key, null)
      }
    ]
  ])
}


# 프록시 서버 키페어는 없어도 무방함
resource "aws_key_pair" "pub_key" {
  key_name   = "pub-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCA1wGQwHj1YsyndGjKZzDWU/lbwhiisVg11U7o3XFkjoV57M207pMjVdk0cGdismABfpq1amJrZ6P+QSzKqu+FHdebZar8C+oe1iwGgJwol5+IPt1vTmryYG+1XoAvmJNZjzY56WlmIZLYmG+VybHGd/OIt06hES/KjHP5FRnTptO1v77nb/EXUfA/WyJPr47Fb9y70jxSt+/0T4Hv397ZLVpenTWN59O8VI5ekjMyWIBwkxL9liFq2EJyTgJKy6dL3VBAQnDh4Ouh2oflD6pwbSD3HLwbDFHh/ChHi97TZ6mvO5bj3EzBP5Nwg5tSSjUosI89GDdnuu+4vv/ubRjn rsa-key-20250629"
}

# Security Group Create (규칙 없이 뼈대만 생성)
resource "aws_security_group" "sg" {
  for_each = local.all_sg_keys
  name     = "sg_${each.key}"
  vpc_id   = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-sg-${each.key}"
  }
}

# Ingress 규칙들을 별도의 리소스로 생성
resource "aws_security_group_rule" "ingress" {
  for_each = { for i, rule in local.ingress_rules : "${rule.sg_key}-${rule.rule_key}" => rule }

  type              = "ingress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id
  
  protocol    = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  
  cidr_blocks = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_key != null ? aws_security_group.sg[each.value.source_security_group_key].id : null
}

# Egress 규칙들을 별도의 리소스로 생성
resource "aws_security_group_rule" "egress" {
  for_each = { for i, rule in local.egress_rules : "${rule.sg_key}-${rule.rule_key}" => rule }

  type              = "egress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id

  protocol    = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port

  cidr_blocks = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_key != null ? aws_security_group.sg[each.value.source_security_group_key].id : null
}


# bastion_ iam(SSManagedInstanceCore) 권한을 가진 instance 
resource "aws_instance" "pri_bastion" {
  for_each = local.pri_sub34_key_by_ids
  ami      = data.aws_ami.latest_linux.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = each.value
  vpc_security_group_ids      = [aws_security_group.sg["bastion"].id]
  iam_instance_profile        = var.ssm_instance_profile_name_from_global

  tags = {
    Name = "${var.pjt_name}-pri-bastion-${regex("-([a-z])-" , each.key)[0]}"
  }

  depends_on = [var.nat_gw]
}

# 주석 처리된 나머지 리소스들은 그대로 유지됩니다.
# ... (기존 파일의 주석 처리된 모든 내용) ...
