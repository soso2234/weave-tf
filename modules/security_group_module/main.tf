# 1. Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.pjt_name}-bastion_sg"
  description = "Bastion host SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.pjt_name}-bastion-sg" }
}

# 2. ALB Security Group
resource "aws_security_group" "tf_alb_sg" {
  name        = "${var.pjt_name}-alb_sg"
  description = "ALB SG"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.pjt_name}-alb-sg" }
}

# ALB ingress rules (80, 443, 3000 외부 허용)
resource "aws_security_group_rule" "tf_alb_sg_ingress" {
  for_each = tomap({ http = 80, https = 443, node = 3000 })

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_alb_sg.id
}

resource "aws_security_group_rule" "tf_alb_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_alb_sg.id
}

# 3. EC2 (Web Server) SG
resource "aws_security_group" "tf_ec2_sg" {
  name        = "${var.pjt_name}-ec2_sg"
  description = "EC2 SG for private web servers"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.pjt_name}-ec2-sg" }
}

# EC2 ingress rules
# ALB → EC2 (80, 443, 3000)
resource "aws_security_group_rule" "tf_ec2_sg_from_alb" {
  for_each = tomap({ http = 80, https = 443, node = 3000, rds = 5432, redis =6379 })

  type                     = "ingress"
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tf_ec2_sg.id
  source_security_group_id = aws_security_group.tf_alb_sg.id
}

# Bastion → EC2 (SSH)
resource "aws_security_group_rule" "tf_ec2_sg_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tf_ec2_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

# EC2 outbound (DB, Redis, Internet, APIs)
resource "aws_security_group_rule" "tf_ec2_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf_ec2_sg.id
}

# 4. RDS (PostgreSQL) SG
resource "aws_security_group" "rds_sg" {
  name   = "${var.pjt_name}-rds-sg"
  vpc_id = var.vpc_id

  tags = { Name = "${var.pjt_name}-rds-sg" }
}

# EC2 → RDS
resource "aws_security_group_rule" "rds_from_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.tf_ec2_sg.id
}

# 5. Redis (ElastiCache) SG
resource "aws_security_group" "redis_sg" {
  name   = "${var.pjt_name}-redis-sg"
  vpc_id = var.vpc_id

  tags = { Name = "${var.pjt_name}-redis-sg" }
}

# EC2 → Redis
resource "aws_security_group_rule" "redis_from_ec2" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = aws_security_group.tf_ec2_sg.id
}
