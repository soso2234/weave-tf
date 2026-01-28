terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# Variables
variable "region" {}
variable "pjt_name" {}
variable "instance_type" {}
variable "ami_id" {}
variable "public_key" {}
variable "db_password" {
  description = "RDS master password"
  sensitive   = true
}

# Locals
locals {
  vpc_cidr = "172.16.0.0/16"

  public_cidrs = [
    "172.16.1.0/24",
    "172.16.2.0/24"
  ]

  private_cidrs = [
    "172.16.3.0/24",
    "172.16.4.0/24",
    "172.16.5.0/24",
    "172.16.6.0/24"
  ]

  subnets = {
    "172.16.1.0/24" = "ap-northeast-2a"
    "172.16.2.0/24" = "ap-northeast-2c"
    "172.16.3.0/24" = "ap-northeast-2a"
    "172.16.4.0/24" = "ap-northeast-2c"
    "172.16.5.0/24" = "ap-northeast-2a"
    "172.16.6.0/24" = "ap-northeast-2c"
  }
}

# VPC
module "vpc" {
  source   = "./modules/vpc_module"
  vpc_cidr = local.vpc_cidr
  pjt_name = var.pjt_name
}

# Subnet
module "subnet" {
  source     = "./modules/subnet_module"
  subnet_map = local.subnets
  vpc_id     = module.vpc.vpc_id
  pjt_name   = var.pjt_name
}

# Route Table
module "route_table" {
  source   = "./modules/route_table_module"
  vpc_id   = module.vpc.vpc_id
  igw_id   = module.vpc.igw_id
  pjt_name = var.pjt_name

  pub_subnets = {
    for cidr in local.public_cidrs :
    cidr => module.subnet.subnet_ids[cidr]
  }

  pri_subnets = {
    for cidr in local.private_cidrs :
    cidr => module.subnet.subnet_ids[cidr]
  }

  public_subnet_id = module.subnet.subnet_ids[local.public_cidrs[0]]
}

# Security Group
module "security_group" {
  source   = "./modules/security_group_module"
  vpc_id   = module.vpc.vpc_id
  pjt_name = var.pjt_name
}

# 키페어
resource "aws_key_pair" "seoul_key" {
  key_name   = "Seoul-key"
  public_key = var.public_key
}

# EC2 Instances (웹 서버)
module "instance" {
  source        = "./modules/instance_module"
  ami_id        = var.ami_id
  instance_type = var.instance_type

  subnet_ids = [
    module.subnet.subnet_ids["172.16.3.0/24"],
    module.subnet.subnet_ids["172.16.4.0/24"]
  ]

  security_group_id = module.security_group.ec2_sg_id
  pjt_name          = var.pjt_name
  region            = "ap-northeast-2"

  depends_on = [
    module.vpc,
    module.route_table
  ]
}

# ALB
module "alb" {
  source = "./modules/load_balancer_module"

  subnet_ids        = [for cidr in local.public_cidrs : module.subnet.subnet_ids[cidr]]
  security_group_id = module.security_group.alb_sg_id
  vpc_id            = module.vpc.vpc_id
  instance_ids      = [module.instance.web_1, module.instance.web_2]
  pjt_name          = var.pjt_name
}

# Bastion Host
module "bastion" {
  source = "./modules/bastion_module"
  ami_id        = var.ami_id
  instance_type = "t3.small"

  subnet_ids        = [module.subnet.subnet_ids["172.16.2.0/24"]]
  security_group_id = module.security_group.bastion_sg_id
  pjt_name          = "${var.pjt_name}-bastion"
  region            = "ap-northeast-2"
  public_key        = "Seoul-key"
}

# ASG (웹 서버)
module "web_asg" {
  source         = "./modules/asg_module"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  pjt_name       = var.pjt_name
  public_key     = "Seoul-key"
  subnet_ids     = [
    module.subnet.subnet_ids["172.16.3.0/24"],
    module.subnet.subnet_ids["172.16.4.0/24"]
  ]
  sg_id           = module.security_group.ec2_sg_id
  vpc_id          = module.vpc.vpc_id
  target_group_arn = module.alb.tg_arn
}

module "rds" {
  source                 = "./modules/rds_module"
  pjt_name               = var.pjt_name
  instance_class         = "db.t3.micro"
  allocated_storage      = 100
  db_name                = "weavedb"
  username               = "weaveadmin"
  multi_az               = false
  rds_sg_id              = module.security_group.rds_sg_id
  rds_subnet_group_name  = module.subnet.rds_subnet_group_name
}




