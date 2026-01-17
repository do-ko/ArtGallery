#  HASŁO DO BAZY
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.db_name}-db-credentials"
  recovery_window_in_days = 0
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>?:.,;"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.username
    password = random_password.db.result
  })
}

# NETWORK
resource "aws_security_group" "postgres" {
  name        = "${var.db_name}-sg"
  description = "PostgreSQL SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.backend_sg_id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCJA EC2
resource "aws_instance" "postgres" {
  ami           = var.aws_ami_id
  instance_type = "t3.small"
  subnet_id     = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.postgres.id]
  iam_instance_profile = var.ec2_profile_name

  user_data = templatefile("${path.module}/user-data-postgres.sh.tpl", {
    db_name  = var.db_name
    username = var.username
    password = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  })
  user_data_replace_on_change = true

  tags = {
    Name = "postgres-ec2"
  }
}

# EBS
resource "aws_ebs_volume" "postgres_data" {
  availability_zone = aws_instance.postgres.availability_zone
  size              = 50
  type              = "gp3"
  encrypted         = true
}

resource "aws_volume_attachment" "postgres_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.postgres_data.id
  instance_id = aws_instance.postgres.id
}
