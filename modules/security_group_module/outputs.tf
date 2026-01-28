output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.tf_ec2_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.tf_alb_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
