data "terraform_remote_state" "app_vpc" {
  backend = "s3"

  config = {
    bucket = "curriki-terraform"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_eks_cluster" "sales-order-system-eks-cluster" {
    name        = var.eks_cluster_name
    role_arn    = aws_iam_role.eks_cluster_role.arn
    
    vpc_config  {
        subnet_ids = data.terraform_remote_state.app_vpc.outputs.subnet_ids
    }
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role"

    assume_role_policy = <<POLICY
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "sales-order-system-AmazonEKSClusterPolicy" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role        = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "sales-order-system-AmazonEKSServicePolicy" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role        = aws_iam_role.eks_cluster_role.name
}