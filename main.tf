# to get each element from map 
# [for k,v in values(var.subnets) : element(values(var.subnets),k)["az"]] # gets each az
# data "aws_ami" "latest_ami" {
#   most_recent = true
#   owners      = "137112412989"

#   filter = {
#     name   = "name"
#     values = ["ami-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }


locals {
  region       = "us-east-1"
  cluster_name = "${var.basename}-cluster"
  tags = {
    Created     = "${var.basename}-Terraform"
    Environment = "${var.basename}"

  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "${var.basename}-vpc"
  cidr            = var.cidr_vpc
  azs             = [for k, v in values(var.subnets) : element(values(var.subnets), k)["az"]]
  private_subnets = [for k, v in values(var.subnets) : element(values(var.subnets), k)["cidr_prv"]]
  public_subnets  = [for k, v in values(var.subnets) : element(values(var.subnets), k)["cidr_pub"]]

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}

# Create eks cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version        = "1.21"
  cluster_name           = local.cluster_name
  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  kubeconfig_output_path = "~/.kube/"


  worker_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 5
    },
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]

  # worker_groups_launch_template = [
  #   {
  #     name                 = "spot-1-micro"
  #     instance_types       = "t2.micro"
  #     spot_instance_pools  = 3
  #     asg_max_size         = 3
  #     asg_desired_capacity = 1
  #     kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #     public_ip            = true
  #   },
  #   {
  #     name                 = "worker-group-1-regular"
  #     instance_type        = "t2.micro"
  #     asg_desired_capacity = 1
  #     public_ip            = true
  #     tags = [{
  #       key                 = "ExtraTag"
  #       value               = "TagValue"
  #       propagate_at_launch = true
  #     }]
  #   }
  # ]

}

resource "null_resource" "java"{
  depends_on = [module.eks_cluster]
  provisioner "local-exec" {
    command = "aws eks --region ${local.region}  update-kubeconfig --name $AWS_CLUSTER_NAME"
    environment = {
      AWS_CLUSTER_NAME = "${local.cluster_name}"
    }
  }
}

