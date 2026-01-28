// ALB 생성
resource "aws_lb" "tf_alb" {
  name               = "${var.pjt_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "${var.pjt_name}-alb"
  }
}

// 대상 그룹 생성
resource "aws_lb_target_group" "tf_tg" {
  name     = "${var.pjt_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

// Listener 생성
resource "aws_lb_listener" "tf_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_tg.arn
  }
}

// Output
output "alb_arn" {
  value = aws_lb.tf_alb.arn
}

output "tg_arn" {
  value = aws_lb_target_group.tf_tg.arn
}
