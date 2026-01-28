output "rds_instance_id" {
  value       = aws_db_instance.weave.id
  description = "ID of the RDS instance"
}

output "rds_endpoint" {
  value       = aws_db_instance.weave.endpoint
  description = "Endpoint address of the RDS instance"
}

output "rds_port" {
  value       = aws_db_instance.weave.port
  description = "Port of the RDS instance"
}

output "rds_parameter_group_name" {
  value       = aws_db_parameter_group.rds_parameter_group.name
  description = "Name of the RDS parameter group"
}
