provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "spring-app-cluster"
  cluster_version = "1.27"
  subnet_ids         = ["subnet-070c47b4c3a8617e1", "subnet-06b98bd54235f7c56"] 
  vpc_id          = "vpc-07d95f7f3f036f70b"

 eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

resource "aws_iam_policy" "alb_ingress" {
  name        = "ALBIngressController"
  description = "Policy for ALB Ingress Controller"

  policy = file("alb-ingress-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  role       = module.eks.worker_iam_role_name
  policy_arn = aws_iam_policy.alb_ingress.arn
}

}