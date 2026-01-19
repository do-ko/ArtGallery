#  SECRET DO MINIIO
resource "aws_secretsmanager_secret" "minio_secret" {
  name                    = "minio-secret"
  recovery_window_in_days = 0
}

resource "random_password" "minio_secret" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret_version" "minio_secret" {
  secret_id = aws_secretsmanager_secret.minio_secret.id

  secret_string = jsonencode({
    access_key = "minio-admin"
    secret_key = random_password.minio_secret.result
  })
}

# NETWORK
resource "aws_security_group" "minio" {
  name        = "mini-io-sg"
  description = "MiniIO SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "minio" {
  name        = "minio-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/minio/health/live"
    port                = "9000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "minio" {
  listener_arn = var.minio_alb_listener_http_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minio.arn
  }

  condition {
    path_pattern {
      values = ["/bucket/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "minio" {
  target_group_arn = aws_lb_target_group.minio.arn
  target_id        = aws_instance.minio.id
  port             = 9000
}


# INSTANCJA EC2
resource "aws_instance" "minio" {
  ami                  = var.aws_ami_id
  instance_type        = "t3.small"
  subnet_id            = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.minio.id]
  iam_instance_profile = var.ec2_profile_name

  user_data = templatefile("${path.module}/user-data-minio.sh.tpl", {
    access_key = jsondecode(aws_secretsmanager_secret_version.minio_secret.secret_string)["access_key"]
    secret_key = jsondecode(aws_secretsmanager_secret_version.minio_secret.secret_string)["secret_key"]
  })
  user_data_replace_on_change = true

  tags = {
    Name = "minio-ec2"
  }
}


# EBS
resource "aws_ebs_volume" "minio_data" {
  availability_zone = aws_instance.minio.availability_zone
  size              = 100
  type              = "gp3"
  encrypted         = true
}

resource "aws_volume_attachment" "minio_data" {
  device_name = "/dev/xvdg"
  volume_id   = aws_ebs_volume.minio_data.id
  instance_id = aws_instance.minio.id
}