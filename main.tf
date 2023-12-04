resource "aws_docdb_subnet_group" "main" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids =  var.subnet_ids
  tags       =  merge(local.tags, { Name = "${local.name_prefix}-subnet-group"})
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${local.name_prefix}-cluster"
  engine =  "docdb"
  master_username         = data.aws_ssm_document.master_username.value
  master_password         = data.aws_ssm_document.master_password.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.main.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  engine_version = var.engine_version
  tags       =              merge(local.tags, { Name = "${local.name_prefix}-cluster"})
}
resource "aws_docdb_cluster_parameter_group" "main" {
  family      = var.engine_family
  name        = "${local.name_prefix}-pg"
  description = "${local.name_prefix}-pg"
  tags       =  merge(local.tags, { Name = "${local.name_prefix}-pg"})
}

resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix}-sg"
  vpc_id      =  var.vpc_id
  tags        =  merge(var.tags, { Name = "${local.name_prefix}-sg"})

  ingress {
    description      = "DOCDB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.sg_ingress_cidr

}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_docdb_cluster_instance" "main" {
  count              = var.instance_count
  identifier         = "${local.name_prefix}-cluster-instance-${count.index+1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class
}

//will do later point of time for below
//resource "aws_docdb_cluster" "default" {
  //cluster_identifier = "docdb-cluster-demo"
 // availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
 // master_username    = "foo"
 // master_password    = "barbut8chars"
//}