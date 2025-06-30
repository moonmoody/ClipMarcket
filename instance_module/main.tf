locals {
  pub_sub_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if startswith(key, "pub_")
  }

  # AZ별로 1개씩만 고르기 (예: 2a, 2c 중복 제거)
  pub_subnet_ids_by_az = {
    for az, pair in {
      for key, id in local.pub_sub_key_by_id : var.subnets[key].az => {
        key = key
        id  = id
      }
    } : az => pair.id
  }

  pub_subnet_ids = values(local.pub_subnet_ids_by_az)  # ALB에 넣을 list(string)
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
resource "aws_security_group" "sg_pub" {
  name        = "sg_pub"
  description = "sg_pub"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.pjt_name}_sg_pub"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_pub_ingress" {
  for_each = {
    "icmp" : "-1",
    "http" : "80",
    "https" : "443",
    "ssh" : "22"
  }
  security_group_id = aws_security_group.sg_pub.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  ip_protocol       = each.key != "icmp" ? "tcp" : each.key # icmp 이외에는 tcp로 인식시켜야 함.
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "sg_pub_egress" {
  security_group_id = aws_security_group.sg_pub.id
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
  vpc_security_group_ids      = [aws_security_group.sg_pub.id]
  key_name                    = "pub_key"

  tags = {
    Name = "${var.pjt_name}_pub_${regex("_([a-z])_", each.key)[0]}"
  }

  depends_on = [var.nat_gw]
}

# Create Target Group
resource "aws_lb_target_group" "pub_sg_tg" {
  name     = "web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Attachment Target Group 
resource "aws_lb_target_group_attachment" "pub_tg_web_att" {
  for_each = aws_instance.pub_instance
  target_group_arn = aws_lb_target_group.pub_sg_tg.arn
  target_id        = each.value.id
  port             = 80
}

# Create Listener
resource "aws_lb_listener" "pub_web_listener" {
  load_balancer_arn = aws_lb.pub_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pub_sg_tg.arn
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
  name        = "${var.pjt_name}-alb-sg"
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
    Name = "${var.pjt_name}-alb-sg"
  }
}

