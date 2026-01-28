variable "vpc_id" {}
variable "pjt_name" {}
variable "subnet_map" { type = map(string) }

# RDS 서브넷 그룹용 서브넷 선택 (private 서브넷 중 선택)
variable "rds_subnet_map" {
  type = map(string)
  default = {}
}
