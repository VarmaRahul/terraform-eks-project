resource "aws_eks_cluster" "main" {
  name     = "${local.env}-${local.eks_name}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = local.eks_version

  vpc_config {
    subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = [
      "${var.my_local_ip}/32"
    ]
  }

  upgrade_policy {
    support_type = "EXTENDED"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "${local.env}-${local.eks_name}"
    Environment = local.env
  }
}