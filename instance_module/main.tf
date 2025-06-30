locals {
  pub_sub_key_by_ids = {
    for key, subnet in var.vpc_sub_key_by_ids : key => subnet if startswith(key, "pub_")
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







# Web Node1 인스턴스 생성
# resource "aws_instance" "web_node1" {
#   ami                         = var.ami_id
#   instance_type               = "t3.medium"
#   subnet_id                   = var.subnet_ids
#   vpc_security_group_ids      = [var.security_group_id]
#   associate_public_ip_address = true

#   # user_data = <<-EOF
#   # #!/bin/bash
#   # set -euo pipefail

#   # # 1) 스왑 비활성화
#   # swapoff -a
#   # sed -i '/ swap / s/^/#/' /etc/fstab

#   # # 2) 필수 패키지
#   # apt-get update && apt-get install -y \
#   #   apt-transport-https \
#   #   ca-certificates \
#   #   curl \
#   #   gnupg \
#   #   lsb-release \
#   #   software-properties-common

#   # # 3) Docker & containerd
#   # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#   # add-apt-repository \
#   #   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   #   $(lsb_release -cs) stable"
#   # apt-get update
#   # apt-get install -y docker-ce docker-ce-cli containerd.io

#   # mkdir -p /etc/containerd
#   # containerd config default > /etc/containerd/config.toml
#   # systemctl restart containerd
#   # systemctl enable containerd
#   # systemctl enable docker

#   # # 4) Kubernetes (kubeadm, kubelet, kubectl)
#   # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#   # echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
#   #   > /etc/apt/sources.list.d/kubernetes.list
#   # apt-get update
#   # apt-get install -y kubelet kubeadm kubectl
#   # apt-mark hold kubelet kubeadm kubectl
#   # systemctl enable kubelet

#   # # 5) 재시그널
#   # systemctl daemon-reexec

#   # # 로그 위치 확인: /var/log/cloud-init-output.log
#   # EOF  

#   tags = {
#     Name = "${var.pjt_name}_web_node-1"
#   }
# }


# Web Node2 인스턴스 생성
# resource "aws_instance" "web_node2" {
#   ami                         = var.ami_id
#   instance_type               = "t3.medium"
#   subnet_id                   = var.subnet_ids
#   vpc_security_group_ids      = [var.security_group_id]
#   associate_public_ip_address = true

#   user_data = <<-EOF
#   #!/bin/bash
#   set -euo pipefail

#   # 1) 스왑 비활성화
#   swapoff -a
#   sed -i '/ swap / s/^/#/' /etc/fstab

#   # 2) 필수 패키지
#   apt-get update && apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release \
#     software-properties-common

#   # 3) Docker & containerd
#   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#   add-apt-repository \
#     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#     $(lsb_release -cs) stable"
#   apt-get update
#   apt-get install -y docker-ce docker-ce-cli containerd.io

#   mkdir -p /etc/containerd
#   containerd config default > /etc/containerd/config.toml
#   systemctl restart containerd
#   systemctl enable containerd
#   systemctl enable docker

#   # 4) Kubernetes (kubeadm, kubelet, kubectl)
#   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#   echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
#     > /etc/apt/sources.list.d/kubernetes.list
#   apt-get update
#   apt-get install -y kubelet kubeadm kubectl
#   apt-mark hold kubelet kubeadm kubectl
#   systemctl enable kubelet

#   # 5) 재시그널
#   systemctl daemon-reexec

#   # 로그 위치 확인: /var/log/cloud-init-output.log
#   EOF  

#   tags = {
#     Name = "${var.pjt_name}_web_node-2"
#   }
# }

# 각 리전 main.tf 파일에 데이터 블록 넣기
# 최신 Ubuntu ami 가져오기
# data "aws_ami" "ubuntu" {
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

