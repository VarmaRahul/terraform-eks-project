resource "aws_eks_node_group" "general" {
  cluster_name = aws_eks_cluster.main.name

  node_group_name = "${local.env}-${local.eks_name}-general"

  node_role_arn = aws_iam_role.eks_node.arn

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  ami_type = "AL2023_x86_64_STANDARD"

  instance_types = [
    "t3.medium"
  ]

  disk_size = 30

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${local.env}-${local.eks_name}-general"
    Environment = local.env
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr_readonly
  ]
}