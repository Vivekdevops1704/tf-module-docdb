locals {
    name_prefix = "${var.env}-docdb"
    tags = merge(var.tags, { tf-module-name = "docdb"}, { env = var.env })
    app_subnets_cidr  = [for k, v in lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "db", null), "subnet_ids", null) : v.cidr_block]
}