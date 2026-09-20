# Terraform AWS EKS Infrastructure

This project provisions AWS infrastructure and an Amazon EKS cluster using Terraform, Kubernetes, and Helm.

## Project Structure

```text
terraform-infrastructure/
│
├── terraform_state_bucket/
│   └── Terraform state S3 bucket
│
├── terraform_vpc/
│   └── VPC and networking
│
├── terraform_compute/
│   └── Bastion EC2
│
├── terraform_eks/
│   ├── EKS cluster
│   ├── IAM roles
│   ├── Managed node group
│   ├── EKS add-ons
│   └── AWS Load Balancer Controller IAM
│
└── k8s/
    ├── app.yaml
    └── app-ingress.yaml
```

## Architecture

```text
                         Internet
                            |
                            v
                         AWS ALB
                            |
                AWS Load Balancer Controller
                            |
                 Kubernetes Ingress
                    /            \
                   /              \
                  v                v
          frontend-svc       backend-svc
            ClusterIP          ClusterIP
                |                  |
                v                  v
          Frontend Pod        Backend Pod
                |
                v
           EKS Node Group
```

## AWS Infrastructure

- AWS Region: `ap-south-1`
- VPC CIDR: `10.0.0.0/16`
- Public and private subnets across two Availability Zones
- Internet Gateway
- NAT Gateway
- Bastion EC2
- Amazon EKS
- EKS Managed Node Group

## Terraform

Terraform is separated into independent root modules:

- `terraform_state_bucket` - Terraform remote state S3 bucket
- `terraform_vpc` - VPC and networking
- `terraform_compute` - Bastion EC2
- `terraform_eks` - EKS cluster and Kubernetes infrastructure

Each root module has its own Terraform state.

## Terraform State

State is stored remotely in S3:

```text
terraform-state-vrahul-mumbai
```

State paths:

```text
vpc/dev/terraform.tfstate
compute/dev/terraform.tfstate
eks/dev/terraform.tfstate
```

The state bucket has:

- Public access blocked
- Server-side encryption enabled
- HTTPS-only access

## EKS

Cluster name:

```text
dev-project
```

Kubernetes version:

```text
1.36
```

Worker nodes run in private subnets.

## EKS Add-ons

The cluster uses:

- VPC CNI
- CoreDNS
- kube-proxy

## AWS Load Balancer Controller

The AWS Load Balancer Controller is installed using Helm.

Terraform manages:

- OIDC provider
- IAM policy
- IAM role
- IAM policy attachment

Helm manages the controller deployment.

The Kubernetes service account uses IRSA to assume the IAM role.

## Kubernetes Application

The application contains:

```text
Frontend
   |
   +-- frontend-svc

Backend
   |
   +-- backend-svc
```

Both services use `ClusterIP`.

The AWS Load Balancer Controller creates an internet-facing Application Load Balancer from the Kubernetes Ingress.

## Useful Commands

### Terraform

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Kubernetes

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc
kubectl get ingress
```

### Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm search repo eks/aws-load-balancer-controller
```

## Technologies

- AWS
- Terraform
- Amazon EKS
- Kubernetes
- Helm
- AWS Load Balancer Controller
- IAM
- Amazon S3
- EC2
