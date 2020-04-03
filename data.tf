data "aws_caller_identity" "current" {}

data terraform_remote_state "vpc" {
  backend = "s3"

  config = {
    bucket         = "itsre-state-517826968395"
    key            = "terraform/deploy.tfstate"
    dynamodb_table = "itsre-state-517826968395"
    region         = "eu-west-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
