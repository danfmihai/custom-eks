# to get each element from map 
# [for k,v in values(var.subnets) : element(values(var.subnets),k)["az"]] # gets each az

locals {
  region = "us-east-1"

  tags = {
    Created   = "${var.basename}-Terraform"
    Environment = "${var.basename}"
  
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.basename}-vpc"
  cidr = var.cidr_vpc
  azs             = [for k,v in values(var.subnets) : element(values(var.subnets),k)["az"]]
  private_subnets = [for k,v in values(var.subnets) : element(values(var.subnets),k)["cidr_prv"]]
  public_subnets = [for k,v in values(var.subnets) : element(values(var.subnets),k)["cidr_pub"]]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

