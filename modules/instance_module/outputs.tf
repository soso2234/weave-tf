output "web_1" {
  value = aws_instance.tf_ec2[0].id
}

output "web_2" {
  value = aws_instance.tf_ec2[1].id
}
