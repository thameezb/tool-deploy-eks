# tool-deploy-eks

TF & Packer deployment for an example EKS Cluster

## Notes

https://aws.amazon.com/blogs/containers/amazon-ecs-vs-amazon-eks-making-sense-of-aws-container-services/

Amazon Elastic Kubernetes Service (Amazon EKS) is a managed service that you can use to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes. Kubernetes is an open-source system for automating the deployment, scaling, and management of containerized applications. Amazon EKS

Runs up-to-date versions of the open-source Kubernetes software, so you can use all of the existing plugins and tooling from the Kubernetes community. Applications that are running on Amazon EKS are fully compatible with applications running on any standard Kubernetes environment, no matter whether they're running in on-premises data centers or public clouds. This means that you can easily migrate any standard Kubernetes application to Amazon EKS without any code modification.

Amazon EKS runs a single tenant Kubernetes control plane for each cluster. The control plane infrastructure is not shared across clusters or AWS accounts. The control plane consists of at least two API server instances and three etcd instances that run across three Availability Zones within an AWS Region.

https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html

Automatic node labeling requries a controller to watch for new nodes and label accordingly -> <https://github.com/kubernetes/kubernetes/issues/63022>

Does not seem to support NameSpaceAutoCreation as expected

### Pricing

https://aws.amazon.com/eks/pricing/
$0.10 per hour for each Amazon EKS cluster that you create. And then standard compute costs

### SLA

https://aws.amazon.com/eks/sla/

### Security

- All of the data stored by the etcd nodes and associated Amazon EBS volumes is encrypted using AWS KMS.
- Each Amazon EKS cluster control plane is single-tenant and unique, and runs on its own set of Amazon EC2 instances.
- https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
- Can enable SGs at a POD level -> https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
  - Disables internal Calico Netpols in favor of SGs
  - Not supported in NodeLocalDNS clusters
- Can integrate Service Account Auth with IAM -> https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
  - per SA level (vs node level)
- supports encryption of secret objects

### Serverless (Fargate)

https://docs.aws.amazon.com/eks/latest/userguide/fargate.html

Cannot build docker images using docker in Fargate, need to use Kaniko or external EC2 runner
https://aws.amazon.com/blogs/containers/how-to-build-container-images-with-amazon-eks-on-fargate/

Neuvector does not support Fargate pods (on the roadmap)

Calico does not support Fargate pods (Netpols) 

### Virtual Machines (EC2)

Bog standard K8s instance, except needs to be running on an EKS-optomized AMI. A non-hardened instance from Canonical is available -> https://cloud-images.ubuntu.com/aws-eks/

Neuvector does support EC2

Calico does support EC2 pods

### Other

- k8s updates -> EKS updates controlplane, workers need to be updated at AMI level after the fact

### External Manager overlaying Cloud managed Kubernetes Cluster (Rancher atop EKS)

- Requires an existing K8s cluster in which to run the rancher services on
- Does not support fargate pods -> https://github.com/rancher/rancher/issues/24909
- Helpful resources
  - <https://aws.amazon.com/blogs/opensource/managing-eks-clusters-rancher/>
  - <https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/>
  - <https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/registered-clusters/#additional-features-for-registered-eks-and-gke-clusters>
  - [architecture](rancher-architecture-rancher-api-server.svg)
- <https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html> -> required to give permissions
- Enable service account IAM
  - <https://levelup.gitconnected.com/using-iam-roles-to-allow-the-pods-in-aws-eks-to-read-the-aws-s3-bucket-be493fbdda84>
  - <https://aws.amazon.com/premiumsupport/knowledge-center/eks-restrict-s3-bucket/>
  - example `aws-auth` config-map 
  ```yaml
  apiVersion: v1
  data:
    mapRoles: |
      - groups:
        - system:bootstrappers
        - system:nodes
        - system:node-proxier
        rolearn: arn:aws:iam::135703251640:role/ag-allow_all_eks_pod_fargate-role
        username: system:node:{{SessionName}}
      - groups:
        - system:bootstrappers
        - system:nodes
        rolearn: arn:aws:iam::135703251640:role/ag-allow_all_ec2-role
        username: system:node:{{EC2PrivateDNSName}}
    mapUsers: |
      - groups:
        - system:masters
        userarn: arn:aws:iam::135703251640:user/svc-temp-eks-user
        username: admin
  kind: ConfigMap
  ```