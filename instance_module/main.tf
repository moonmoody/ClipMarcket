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
  # ingress와 egress에 있는 모든 key
  all_sg_keys = toset(concat(
    keys(var.ingress_rule_config),
    keys(var.egress_rule_config)
  ))
}


# 프록시 서버 키페어는 없어도 무방함
resource "aws_key_pair" "pub_key" {
  key_name   = "pub-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCA1wGQwHj1YsyndGjKZzDWU/lbwhiisVg11U7o3XFkjoV57M207pMjVdk0cGdismABfpq1amJrZ6P+QSzKqu+FHdebZar8C+oe1iwGgJwol5+IPt1vTmryYG+1XoAvmJNZjzY56WlmIZLYmG+VybHGd/OItO6hES/KjHP5FRnTptO1v77nb/EXUfA/WyJPr47Fb9y70jxSt+/0T4Hv397ZLVpenTWN59O8VI5ekjMyWIBwkxL9liFq2EJyTgJKy6dL3VBAQnDh4Ouh2oflD6pwbSD3HLwbDFHh/ChHi97TZ6mvO5bj3EzBP5Nwg5tSSjUosI89GDdnuu+4vv/ubRjn rsa-key-20250629"
}

resource "aws_key_pair" "pri_key" {
  key_name   = "pri-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2tdliuf5tpkg8s9ZZ+hcrLG2rrM5J7452CeNNHJ5OV6UGAy+yCnIhRRtL+tUEkypRzJ6j5v2uxyaUgZ45OmIoxR25lrN7JGxY3K7JWnfDhwWc5CSt9L2cmmMfqr/+Okbb+HnFH538syzDqaE2hiuVTIjVCa4gpTbpBn0JLF2ShfMkB8nXsS0ezvRAOAh1bd5CENYRlndytjboEbB5xQPECJLscWFbsDi3Ys0suqxgKTm1c7ftlhv5cXmCSczNxravz41+T7k+GqhePgKGap/KShDB7nMlu8qgtUqLxaHRBRouClvs0yj3DAKFkJLvThOPV4TmWEtBLgQKCd4SQk3T rsa-key-20250708"
}


# Security Group Create with dynamic ingress/egress rules
resource "aws_security_group" "sg" {
  for_each = local.all_sg_keys
  name     = "sg_${each.key}"
  vpc_id   = var.vpc_id

  dynamic "ingress" {
    # vigrinia 에 proxy = null 이 들어가는 현상이 있어서..
    for_each = var.ingress_rule_config[each.key] != null ? var.ingress_rule_config[each.key] : {}
    content {
      # from_port와 to_port가 정의되지 않은 경우 기본값 0을 사용
      from_port   = lookup(ingress.value, "from_port", 0)
      to_port     = lookup(ingress.value, "to_port", 0)
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr]
    }
  }

  dynamic "egress" {
    for_each = var.egress_rule_config[each.key] != null ? var.egress_rule_config[each.key] : {}
    content {
      from_port   = lookup(egress.value, "from_port", 0)
      to_port     = lookup(egress.value, "to_port", 0)
      protocol    = egress.value.protocol
      cidr_blocks = [egress.value.cidr]
    }
  }

  tags = {
    Name = "${var.pjt_name}-sg-${each.key}"
  }
}


# Seoul 리전에서만 생성.
# 프록시 서버 private instance
resource "aws_instance" "pri_proxy" {
  for_each = data.aws_region.current.id == "ap-northeast-2" ? local.pri_sub34_key_by_ids : {}
  ami      = data.aws_ami.latest_linux.id
  # instance_type               = "t4g.medium"
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = each.value
  vpc_security_group_ids      = data.aws_region.current.id == "ap-northeast-2" ? [aws_security_group.sg["proxy"].id] : []
  # key_name                    = aws_key_pair.pri_key.key_name
  user_data = <<-EOF
              #!/bin/bash
              # SSH 비밀번호 인증 활성화
              sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
              # sshd 서비스 재시작하여 변경사항 적용
              systemctl restart sshd
              # ec2-user의 비밀번호 설정
              echo 'ec2-user:mypassword' | chpasswd
              EOF
  # user_data = <<-EOF
  #             #!/bin/bash
  #             aws s3 cp s3://my-bucket/my_key.pem /home/ec2-user/my_key.pem
  #             chmod 400 /home/ec2-user/my_key.pem
  #             EOF

  tags = {
    Name = "${var.pjt_name}-pri-proxy-${regex("-([a-z])-" , each.key)[0]}"
  }

  depends_on = [var.nat_gw]
}

# bastion_ iam(SSManagedInstanceCore) 권한을 가진 instance 
resource "aws_instance" "pri_bastion" {
  ami      = data.aws_ami.latest_linux.id
  instance_type               = "t3.small"
  associate_public_ip_address = false
  subnet_id                   = local.pri_sub34_key_by_ids.pri-a-3
  vpc_security_group_ids      = [aws_security_group.sg["bastion"].id]
  # 추후에 global에서 가져와서 주입하는 형식으로 수정 필요.
  # iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  iam_instance_profile        = var.ssm_instance_profile_name_from_global
  # key_name                    = aws_key_pair.pub_key.key_name

  tags = {
    Name = "${var.pjt_name}-pri-bastion"
  }

  depends_on = [var.nat_gw]
}

# Create Target Group
resource "aws_lb_target_group" "pub_tg" {
  name     = "pub-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "${var.pjt_name}-pub-alb-tg"
  }
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
  name        = "${var.pjt_name}-sg-pub-alb"
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
    Name = "${var.pjt_name}-sg-pub-alb"
  }
}

# Private Load Balancer
# Seoul 리전에서만 생성.
resource "aws_lb_target_group" "pri_tg" {
  count = data.aws_region.current.id == "ap-northeast-2" ? 1 : 0
  name     = "pri-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "pri_tg_att" {
  for_each = data.aws_region.current.id == "ap-northeast-2" ? aws_instance.pri_proxy : {}
  target_group_arn = aws_lb_target_group.pri_tg[0].arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "pri_alb_listener" {
  count = data.aws_region.current.id == "ap-northeast-2" ? 1 : 0
  load_balancer_arn = aws_lb.pri_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pri_tg[0].arn
  }
}

resource "aws_lb" "pri_alb" {
  count = data.aws_region.current.id == "ap-northeast-2" ? 1 : 0
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
  count = data.aws_region.current.id == "ap-northeast-2" ? 1 : 0
  name        = "${var.pjt_name}-sg-pri-alb"
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
    Name = "${var.pjt_name}-sg-pri-alb"
  }
}

# Launch Template
resource "aws_launch_template" "pub_lt" {
  name_prefix   = "${var.pjt_name}-pub-"
  image_id      = data.aws_ami.latest_linux.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.pub_key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups  = [aws_security_group.sg["pub"].id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.pjt_name}-pub-instance"     # 태그 설정이 필수.
    }
  }

  depends_on = [var.nat_gw]
}

# Auto Scaling
resource "aws_autoscaling_group" "pub_asg" {
  for_each = local.pub_sub_key_by_ids
  name                = "${var.pjt_name}-pub-asg-${regex("-([a-z])-" , each.key)[0]}"
  desired_capacity    = var.pub_asg_config.desired_capacity
  max_size            = var.pub_asg_config.max_size
  min_size            = var.pub_asg_config.min_size
  vpc_zone_identifier = [each.value]

  launch_template {
    id      = aws_launch_template.pub_lt.id
    version = "$Latest"
  }

  # 실제 생성되는 instance에 적용되는 tag
  tag {
    key                 = "Name"
    value               = "${var.pjt_name}-pub-${regex("-([a-z])-" , each.key)[0]}"
    propagate_at_launch = true
  }
}

# AutoScaling에 Target Group attachment
resource "aws_autoscaling_attachment" "pub_asg_att" {
  for_each = aws_autoscaling_group.pub_asg
  autoscaling_group_name = each.value.id
  lb_target_group_arn    = aws_lb_target_group.pub_tg.arn
}
