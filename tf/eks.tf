//--------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ret_de_test_eks" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/ret_de_test_eks/cluster"
  retention_in_days = 7
}

//--------------------------------------------------------------------------------------------------------------------
// Cluster 
resource "aws_eks_cluster" "ret_de_test_eks" {
  name     = "ret_de_test_eks"
  version  = "1.21"
  role_arn = aws_iam_role.ag-allow_all_eks-role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.allow_all_sg.id]
    subnet_ids              = data.aws_subnets.compute_subnet.ids
  }

  enabled_cluster_log_types = ["api", "audit"]

  // encryption_config{

  // }
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = aws_eks_cluster.ret_de_test_eks.name
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.ret_de_test_eks.name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name      = aws_eks_cluster.ret_de_test_eks.name
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
}

output "endpoint" {
  value = aws_eks_cluster.ret_de_test_eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.ret_de_test_eks.certificate_authority[0].data
}
