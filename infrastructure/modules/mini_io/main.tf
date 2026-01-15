#  SECRET DO MINIIO
resource "aws_secretsmanager_secret" "miniio_secret" {
  name                    = "miniio-secret"
  recovery_window_in_days = 0
}

resource "random_password" "miniio_secret" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>?:.,;"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret_version" "miniio_secret" {
  secret_id = aws_secretsmanager_secret.miniio_secret.id

  secret_string = jsonencode({
    access_key = "minio-admin"
    secret_key = random_password.miniio_secret.result
  })
}

# NETWORK
resource "aws_security_group" "miniio" {
  name        = "mini-io-sg"
  description = "MiniIO SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [var.backend_security_group_id]
  }

  ingress {
    from_port       = 9001
    to_port         = 9001
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "miniio" {
  name        = "miniio-tg"
  port        = 9001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "miniio" {
  listener_arn = var.miniio_alb_listener_http_arn
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.miniio.arn
  }

  condition {
    host_header {
      values = ["minio.${var.alb_dns}"]
    }
  }
}


# INSTANCJA EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "miniio-ec2-profile"
  role = var.role_name
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "miniio" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = "t3.small"
  subnet_id            = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.miniio.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user-data-miniio.sh.tpl", {
    access_key = jsondecode(aws_secretsmanager_secret_version.miniio_secret.secret_string)["access_key"]
    secret_key = jsondecode(aws_secretsmanager_secret_version.miniio_secret.secret_string)["secret_key"]
  })
  user_data_replace_on_change = true

  tags = {
    Name = "miniio-ec2"
  }
}

# EBS
resource "aws_ebs_volume" "miniio_data" {
  availability_zone = aws_instance.miniio.availability_zone
  size              = 100
  type              = "gp3"
  encrypted         = true
}

resource "aws_volume_attachment" "miniio_data" {
  device_name = "/dev/xvdg"
  volume_id   = aws_ebs_volume.miniio_data.id
  instance_id = aws_instance.miniio.id
}