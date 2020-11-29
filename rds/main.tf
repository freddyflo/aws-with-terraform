provider aws {
    region =  "eu-west-3"
}


variable "username" {}
variable "password" {}


resource "aws_db_security_group" "default" {
  name = "rds_sg"

  ingress {
    cidr = "0.0.0.0/0"
  }
}

resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = aws_vpc.vpc_id.id
 
 # Allow all inbound traffic.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}





resource "aws_db_instance" "default" {
  allocated_storage         = 20
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t2.micro"
  name                      = "mydb"
  username                  = var.username
  password                  = var.username
  parameter_group_name      = "default.mysql5.7"
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
  publicly_accessible       = true
  #vpc_security_group_ids    = [aws_security_group.rds.id]
}
