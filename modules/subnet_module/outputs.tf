output "subnet_ids" {
  description = "All subnet IDs created in this module"
  value       = { for k, v in aws_subnet.tf_sn : k => v.id }
}

output "rds_subnet_group_id" {
  description = "RDS subnet group ID"
  value       = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_subnet_group_name" {
  value       = aws_db_subnet_group.rds_subnet_group.name
  description = "RDS DB Subnet Group name"
}
