data "aws_ami" "ag_ret_ami_eks" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ag-ret-eks-*"]
  }
  owners = [data.aws_caller_identity.current.account_id]
}

resource "aws_launch_template" "ret_de_test_eks" {
  name     = "ret_de_test_eks"
  image_id = data.aws_ami.ag_ret_ami_eks.id

  key_name = "test-de"

  credit_specification {
    cpu_credits = "standard"
  }

  instance_type = "m5.2xlarge"

  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]

  user_data = base64encode(templatefile(
    "${path.module}/scripts/bootstrap.sh", {
      EKS_CLUSTER_NAME = "ret_de_test_eks"
    })
  )
}

//--------------------------------------------------------------------------------------------------------------------
// Node Group

resource "aws_eks_node_group" "ret_de_eks" {
  cluster_name    = aws_eks_cluster.ret_de_test_eks.name
  node_group_name = "ret_de_eks"
  node_role_arn   = aws_iam_role.ag-allow_all_ec2-role.arn
  subnet_ids      = data.aws_subnets.compute_subnet.ids

  ami_type      = "CUSTOM"
  capacity_type = "ON_DEMAND"
  // disk_size      = 50
  // instance_types = ["m5.2xlarge"]

  launch_template {
    id      = aws_launch_template.ret_de_test_eks.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 0
  }
  update_config {
    max_unavailable_percentage = 10
  }
  // labels = 


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.ag-allow_all_ec2,
  ]
}
