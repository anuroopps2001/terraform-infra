module "vpc" {
  source = "terraform-aws-modules/vpc/aws" # Source is important, because that's the place from where terraform get the resource blocks

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets = local.intra_subnets   

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = local.env
  }
}