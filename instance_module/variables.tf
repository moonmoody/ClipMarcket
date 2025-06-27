variable "pjt_name" {
  type        = string
  description = "프로젝트 명"
}
variable "ami_id"{
  type = string
}
variable "subnet_ids" {
  type = list
}
variable "security_group_id" {
  type = string
}