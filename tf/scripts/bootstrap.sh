#!/bin/bash
set -eo xtrace
sudo /etc/eks/bootstrap.sh "${EKS_CLUSTER_NAME}"