resource "aws_launch_template" "web_asg" {
  name_prefix   = "${var.pjt_name}-asg-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = "Seoul-key"

  network_interfaces {
    security_groups = [var.sg_id]
  }

  user_data = base64encode(<<-EOT
#!/bin/bash
yum install -y httpd
echo "<h1>Welcome to ${var.pjt_name}</h1>" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.pjt_name}-asg-web"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name_prefix               = "${var.pjt_name}-asg-"
  max_size                  = 4
  min_size                  = 0
  desired_capacity          = 0
  health_check_type         = "EC2"
  health_check_grace_period = 180
  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.web_asg.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

instance_refresh {
  strategy = "Rolling"

  preferences {
    min_healthy_percentage = 90
    instance_warmup        = 180
  }
}

  tag {
    key                 = "Name"
    value               = "${var.pjt_name}-asg-web"
    propagate_at_launch = true
  }
}
