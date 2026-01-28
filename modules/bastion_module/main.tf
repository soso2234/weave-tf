resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[0]
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = "Seoul-key"

  tags = {
    Name = "${var.pjt_name}_bastion"
  }
}
