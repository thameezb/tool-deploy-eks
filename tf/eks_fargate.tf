//--------------------------------------------------------------------------------------------------------------------
// Attach fargate profile (per selector)
resource "aws_eks_fargate_profile" "ret_de_test_fargate" {
  cluster_name           = aws_eks_cluster.ret_de_test_eks.name
  fargate_profile_name   = "ret_de_test_fargate"
  pod_execution_role_arn = aws_iam_role.ag-allow_all_eks_pod_fargate-role.arn
  subnet_ids             = data.aws_subnets.compute_subnet.ids

  selector {
    namespace = "fargate-test"
    labels = {
      deployType = "fargate"
    } 
  }
}