# Uses the community terraform-aws-modules/eks/aws module — provisions the
# control plane, a managed node group, and the OIDC provider for IRSA
# (pod-level AWS auth) all from one module block.
# Check registry.terraform.io/modules/terraform-aws-modules/eks/aws
# for the current version before applying.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # API_AND_CONFIG_MAP supports EKS access entries for the CI/CD IAM user
  # alongside the classic aws-auth ConfigMap approach.
  authentication_mode = "API_AND_CONFIG_MAP"

  # Without this, the identity running Terraform has AWS-level permission
  # to manage the cluster, but no Kubernetes-level RBAC access to its API —
  # under the newer access-entry auth model, cluster creation no longer
  # automatically grants this the way the older aws-auth-only model did.
  # This is what was causing the persistent "Unauthorized" errors on
  # kubernetes_service_account and kubernetes_namespace.
  enable_cluster_creator_admin_permissions = true

  #to reach from my laptop - should not be in production
  cluster_endpoint_public_access = true

  enable_irsa = true

  # EBS CSI driver: required for PersistentVolumeClaims (Redis uses a gp2 PVC).
  # Without it the PVC stays Pending forever on EKS >= 1.23. This replaces the
  # manual eksctl steps from the old repo's EKS/05-ebs-csi-driver.md.
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      # Lets the EBS CSI driver create/attach volumes using the node role
      # (simple option for a demo cluster; IRSA is the stricter production choice).
      iam_role_additional_policies = {
        ebs_csi = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      instance_types = [var.node_instance_type]
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
    }
  }

  # The module's default node security group only allows node-to-node TCP on
  # ports 1025-65535 (plus 53 for DNS). The ratings service listens on :80, so
  # pods on a different node (e.g. Prometheus, or web) could not reach it and
  # scrapes timed out. This opens port 80 between nodes in the same SG.
  node_security_group_additional_rules = {
    ingress_self_http = {
      description = "Node to node HTTP (ratings listens on :80)"
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      self        = true
    }
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "mavic-drone-shop"
  }

  depends_on = [module.eks]
}
