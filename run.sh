#!/bin/bash 

set -eo pipefail

project_name="tool-deploy-eks"

export TF_VAR_project_name=$project_name
export TF_VAR_team_name="delivery-enginering"
export TF_VAR_deployer_name="thameezbo"
export TF_VAR_environment="dev"
export TF_PLAN_PATH=$project_name-dev.tfplan

if [[ -e "env/dev.tfvars" ]]; then envFile=" -var-file=env/dev.tfvars"; fi  

cd tf

if [ -n "$1" ]; then 
  terraform validate
  terraform $@ $envFile
else
  terraform init \
  -backend-config="bucket=ag-dev-state-s3" \
  -backend-config="key=ag-dev-$project_name/state" \
  -backend-config="region=eu-west-1" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=ag-dev-state-locks"
fi


