# Web Node1 인스턴스 생성
resource "aws_instance" "web_node1" {
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet_ids
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  set -euo pipefail

  # 1) 스왑 비활성화
  swapoff -a
  sed -i '/ swap / s/^/#/' /etc/fstab

  # 2) 필수 패키지
  apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

  # 3) Docker & containerd
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io

  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd
  systemctl enable docker

  # 4) Kubernetes (kubeadm, kubelet, kubectl)
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    > /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
  systemctl enable kubelet

  # 5) 재시그널
  systemctl daemon-reexec

  # 로그 위치 확인: /var/log/cloud-init-output.log
  EOF  

  tags = {
    Name = "${var.pjt_name}_web_node-1"
  }
}

# Web Node2 인스턴스 생성
resource "aws_instance" "web_node2" {
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet_ids
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  set -euo pipefail

  # 1) 스왑 비활성화
  swapoff -a
  sed -i '/ swap / s/^/#/' /etc/fstab

  # 2) 필수 패키지
  apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

  # 3) Docker & containerd
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io

  mkdir -p /etc/containerd
  containerd config default > /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd
  systemctl enable docker

  # 4) Kubernetes (kubeadm, kubelet, kubectl)
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    > /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
  systemctl enable kubelet

  # 5) 재시그널
  systemctl daemon-reexec

  # 로그 위치 확인: /var/log/cloud-init-output.log
  EOF  

  tags = {
    Name = "${var.pjt_name}_web_node-2"
  }
}

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

