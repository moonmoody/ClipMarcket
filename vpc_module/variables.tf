variable "pjt_name" {
  type        = string
  description = "프로젝트 명"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC의 CIDR"
}
variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}
variable "nat_gw_azs" {
  type = map(any)
}
