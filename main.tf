provider "aws" {
  region  = "us-west-2"
  version = "~> 2"
}

provider "local" {
  version = "~> 1.2"
}

locals {
  cluster_name    = "my-cluster"
  cluster_version = "1.14"

  map_roles = [
    {
      username = "itsre-admin"
      rolearn  = "arn:aws:iam::178589013767:role/itsre-admin"
      groups   = ["system:masters"]
    },
  ]

  node_groups = {
    node-group-1 = {
      desired_capacity = 2
      max_capactiy     = 5
      min_capacity     = 2
      instance_type    = "t3.small"
      subnets          = data.terraform_remote_state.vpc.outputs.private_subnets

      k8s_labels = {
        Environment = "test"
        Node        = "managed"
      }

      additional_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"           = "true"
      }
    }
  }

  flux_settings = {
    "git.url"  = "git@github.com:limed/eks-cluster-poc"
    "git.path" = "k8s"
  }

  flux_helm_operator_settings = {
    "git.ssh.secretName" = "flux-git-deploy"
  }

}

module "eks" {
  source                      = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name                = local.cluster_name
  cluster_version             = local.cluster_version
  vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets             = data.terraform_remote_state.vpc.outputs.private_subnets
  node_groups                 = local.node_groups
  enable_flux                 = true
  flux_settings               = local.flux_settings
  flux_helm_operator_settings = local.flux_helm_operator_settings
}
