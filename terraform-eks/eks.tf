module "eks" {
  # Import the module template
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # This is the cluster name
  name                   = local.name
  kubernetes_version     = "1.33"
  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Control plane network
  control_plane_subnet_ids = module.vpc.intra_subnets # control plane will use this specific subnet for the master nodes which AWS manages


  # Managing the nodes within the cluster
  eks_managed_node_groups = {

    tws-cluster-ng = {

      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      cluster_addons = {
        vpc_cni = {
          most-recent = true
        }
        kube_proxy = {
          most-recent = true
        }

        coredns = {
          most-recent = true
        }
      }

      instance_types                        = ["t2.medium"]
      attach_cluster_primary_security_group = true #To make sure new nodes, get added into the security group automatically


      min_size     = 2
      max_size     = 10
      desired_size = 2

      capacity_type = "SPOT"
    }
  }

  tags = {
    Environment = local.env
    Terraform   = "true"
  }
}