provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "spring-app-cluster"
  cluster_version = "1.27"
  subnets         = ["subnet-123456", "subnet-789012"] # Replace with your subnets
  vpc_id          = "vpc-123456" # Replace with your VPC ID

  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size  = 3
    }
  ]
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