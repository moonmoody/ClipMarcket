variable "pjt_name" {
  type        = string
  description = "프로젝트 명"
}

variable "vpc_sub_ids" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "nat_gw" {
  type = map(any)
}

variable "sub_ids" {
  description = "퍼블릭 ALB가 사용할 서브넷 ID 목록"
  type        = list(string)
}

variable "subnets" {
  type = map(object({
    cidr = string
    az = string
  }))
}


# variable "ami_id"{
#   type = string
# }

# variable "security_group_id" {
#   type = string
# }