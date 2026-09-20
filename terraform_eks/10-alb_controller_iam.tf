# ---------------------------------------------------------
# AWS Load Balancer Controller - IRSA
# ---------------------------------------------------------

# Get the TLS certificate chain for the EKS OIDC provider.
# Used to obtain the certificate thumbprint required by IAM.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}


# ---------------------------------------------------------
# IAM OIDC Provider
# ---------------------------------------------------------

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name        = "${local.env}-${local.eks_name}-oidc"
    Environment = local.env
  }
}


# ---------------------------------------------------------
# AWS Load Balancer Controller IAM Policy
# ---------------------------------------------------------

resource "aws_iam_policy" "alb_controller" {
  name        = "${local.env}-${local.eks_name}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/alb_controller_policy.json")

  tags = {
    Name        = "${local.env}-${local.eks_name}-alb-controller-policy"
    Environment = local.env
  }
}


# ---------------------------------------------------------
# IAM Role
# ---------------------------------------------------------

resource "aws_iam_role" "alb_controller" {
  name = "${local.env}-${local.eks_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(
              aws_eks_cluster.main.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:aud" = "sts.amazonaws.com"

            "${replace(
              aws_eks_cluster.main.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${local.env}-${local.eks_name}-alb-controller-role"
    Environment = local.env
  }
}


# ---------------------------------------------------------
# Attach Controller Policy to Role
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}


# ---------------------------------------------------------
# Outputs
# ---------------------------------------------------------

output "alb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}