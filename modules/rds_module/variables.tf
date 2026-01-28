variable "pjt_name" {}
variable "instance_class" { default = "db.t3.micro" }
variable "allocated_storage" { default = 100 }
variable "db_name" { default = "weavedb" }
variable "username" { default = "weaveadmin" }
variable "multi_az" { default = false }
variable "rds_sg_id" {}
variable "rds_subnet_group_name" {
  description = "RDS Subnet Group name"
}
