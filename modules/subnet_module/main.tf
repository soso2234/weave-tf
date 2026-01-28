resource "aws_subnet" "tf_sn" {
  for_each          = var.subnet_map
  vpc_id            = var.vpc_id
  cidr_block        = each.key
  availability_zone = each.value

  tags = {
    Name = "${var.pjt_name}_${each.key}_sn"
  }
}

# RDS용 서브넷 그룹 (개발/테스트용)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.pjt_name}-rds-subnet-group"
  subnet_ids = [
    aws_subnet.tf_sn["172.16.5.0/24"].id,
    aws_subnet.tf_sn["172.16.6.0/24"].id
  ]
  tags = {
    Name = "${var.pjt_name}-rds-subnet-group"
  }
}
