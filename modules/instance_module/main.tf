// EC2 인스턴스 생성
resource "aws_instance" "tf_ec2" {
  count = length(var.subnet_ids)

  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = [var.security_group_id]
  key_name = "Seoul-key"


  user_data = <<-EOT
#!/bin/bash
yum install -y httpd
systemctl enable httpd
systemctl start httpd
EOT

  tags = {
    Name = "${var.pjt_name}_web_${count.index + 1}"
  }
}
