variable "pjt_name" {
  type        = string
  description = "프로젝트 명"
}

variable "vpc_sub_key_by_ids" {
  type = map(any)
}

variable "vpc_id" {
  type = string
}

variable "nat_gw" {
  type = map(any)
}


# variable "ami_id"{
#   type = string
# }



# variable "security_group_id" {
#   type = string
# }