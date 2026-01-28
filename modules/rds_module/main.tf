# Parameter Group (개발/테스트용)
resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "${var.pjt_name}-pg16-11"
  family      = "postgres16"
  description = "Dev/Test parameter group for Postgres 16.11"
}

# RDS Instance
resource "aws_db_instance" "weave" {
  identifier            = "${var.pjt_name}-postgres"
  engine                = "postgres"
  engine_version        = "16.11"
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name                = var.db_name
  username               = var.username
  password               = "weaveadmin"

  db_subnet_group_name   = var.rds_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false
  multi_az            = var.multi_az
  deletion_protection = false

  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name
  skip_final_snapshot  = true

  tags = {
    Name = "${var.pjt_name}-postgres"
  }
}
