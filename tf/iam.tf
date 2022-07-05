//--------------------------------------------------------------------------------------------------------------------
// Creates IAM role
resource "aws_iam_role" "ag-allow_all_eks-role" {
  name = "ag-allow_all_eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

// Create IAM OID Auth Provider
data "tls_certificate" "ret_de_test_eks" {
  url = aws_eks_cluster.ret_de_test_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "ag-ret-test-eks" {
  url = aws_eks_cluster.ret_de_test_eks.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    data.tls_certificate.ret_de_test_eks.certificates[0].sha1_fingerprint,
  ]
}

resource "aws_iam_role" "ag-allow_all_k8s-role" {
  name = "ag-allow_all_k8s-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.ag-ret-test-eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.ag-ret-test-eks.url, "https://", "")}:aud" = [
              "sts.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "ag-allow_all_eks" {
  role       = aws_iam_role.ag-allow_all_eks-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.ag-allow_all_eks-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "ag-allow_all_k8s" {
  role       = aws_iam_role.ag-allow_all_k8s-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}

//--------------------------------------------------------------------------------------------------------------------
# EC2
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ag-allow_all_ec2-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ag-allow_all_ec2-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ag-allow_all_ec2-role.name
}

// EC2 Instances
resource "aws_iam_role" "ag-allow_all_ec2-role" {
  name = "ag-allow_all_ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "ag-allow_all_ec2" {
  role       = aws_iam_role.ag-allow_all_ec2-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}

resource "aws_iam_instance_profile" "ag-allow_all_ec2" {
  name = "ag-allow_all_ec2"
  role = aws_iam_role.ag-allow_all_ec2-role.name
}


//--------------------------------------------------------------------------------------------------------------------
# Fargate 
// Creates IAM role
resource "aws_iam_role" "ag-allow_all_eks_pod_fargate-role" {
  name = "ag-allow_all_eks_pod_fargate-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "allow_all_eks_pod_fargate" {
  role       = aws_iam_role.ag-allow_all_eks_pod_fargate-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}
