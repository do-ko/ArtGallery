# SG dla ALB
resource "aws_security_group" "alb" {
  name   = "${var.lb_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "app" {
  name               = var.lb_name
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

# Target groups
resource "aws_lb_target_group" "fe" {
  name        = var.fe_tg_name
  port        = var.fe_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path    = var.fe_health_path
    matcher = "200-399"
  }
}

resource "aws_lb_target_group" "be" {
  name        = var.be_tg_name
  port        = var.be_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path    = var.be_health_path
    matcher = "200-399"
  }
}

# Listener 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn
  }
}

# Rule: /api/* -> backend
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn
  }

  condition {
    path_pattern {
      values = [var.api_path_pattern]
    }
  }
}
