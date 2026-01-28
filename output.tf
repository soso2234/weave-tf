output "web_1" {
  value = module.instance.web_1
}

output "web_2" {
  value = module.instance.web_2
}

output "dev_rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "dev_rds_instance_id" {
  value = module.rds.rds_instance_id
}