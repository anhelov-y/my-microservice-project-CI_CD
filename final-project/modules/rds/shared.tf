resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets
  tags       = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "rds" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.project_name}-rds-pg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot" 
  }

  parameter {
    name  = "log_statement"
    value = "ddl" 
  }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.project_name}-aurora-pg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = "1000" 
    apply_method = "pending-reboot" 
  }

  parameter {
    name  = "log_statement"
    value = "ddl" 
  }
}