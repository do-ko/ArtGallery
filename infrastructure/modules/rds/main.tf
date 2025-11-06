#  HASŁO DO BAZY
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.db_name}-db-credentials"
  tags = var.tags
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
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.db_name}-rds-sg"
  description = "RDS PostgreSQL SG"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCJA BAZY
resource "aws_db_instance" "postgres" {
  identifier              = "${var.db_name}-pg"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name

  username                = var.username
  password = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]


  allocated_storage       = var.allocated_storage
  storage_encrypted       = true
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  multi_az                = var.multi_az
  deletion_protection     = var.deletion_protection

  backup_retention_period = 1
  apply_immediately       = true

  tags = var.tags
}
