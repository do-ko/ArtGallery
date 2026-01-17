# NETWORK
resource "aws_security_group" "prometheus" {
  name   = "prometheus-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/prometheus/-/healthy"
    protocol            = "HTTP"
    port                = "9000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = var.alb_listener_http_arn
  priority     = 150

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "prometheus" {
  target_group_arn = aws_lb_target_group.prometheus.arn
  target_id        = aws_instance.prometheus.id
  port             = 9090
}

# EC2
resource "aws_instance" "prometheus" {
  ami                    = var.aws_ami_id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.prometheus.id]
  iam_instance_profile   = var.ec2_profile_name

  user_data = templatefile(
    "${path.module}/user-data-prometheus.sh.tpl",
    {
      alb_dns = var.alb_dns,
    }
  )
  user_data_replace_on_change = true

  tags = {
    Name = "prometheus-ec2"
  }
}

