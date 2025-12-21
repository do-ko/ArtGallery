resource "aws_security_group" "keycloak" {
  name   = "keycloak-sg"
  vpc_id = var.keycloak_vpc_id

  ingress {
    from_port       = 8180
    to_port         = 8180
    protocol        = "tcp"
    security_groups = [var.keycloak_alb_sg_id]
  }

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [var.keycloak_alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "keycloak" {
  name        = "keycloak-tg"
  port        = 8180
  protocol    = "HTTP"
  vpc_id     = var.keycloak_vpc_id
  target_type = "instance"

  health_check {
    path                = "/health/ready"
    protocol            = "HTTP"
    port                = "9000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "keycloak" {
  listener_arn = var.keycloak_alb_listener_http_arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak.arn
  }

  condition {
    path_pattern {
      values = ["/admin/*", "/realms/*", "/resources/*"]
    }
  }
}


# INSTANCJA EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "keycloak-ec2-profile"
  role = var.role_name
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "keycloak" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.keycloak.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/user-data-keycloak.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "keycloak-ec2"
  }
}


resource "aws_lb_target_group_attachment" "keycloak" {
  target_group_arn = aws_lb_target_group.keycloak.arn
  target_id        = aws_instance.keycloak.id
  port             = 8180
}
