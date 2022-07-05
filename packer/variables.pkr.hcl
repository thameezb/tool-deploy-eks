variable "region" {
  description = "Allowed AWS regions for deployments (af-south-1)"
  type        = string
  default     = "af-south-1"
  validation {
    condition     = contains(["eu-west-1", "af-south-1"], var.region)
    error_message = "ERROR: Invalid AWS region for deployments. Valid regions are eu-west-1 or af-south-1."
  }
}

variable "environment" {
  description = "Name of deploy environment eg, dev, shared-global for given resources"
  type        = string
  validation {
    condition     = contains(["dev"], var.environment)
    error_message = "ERROR: Invalid deployment environment. Valid environment names are dev"
  }
  default     = "dev"
}

variable "team_name" {
  description = "Team name"
  type        = string
  default     = "DE"
}

variable "deployer_name" {
  description = "Name of person who deployed this project."
  type        = string
  default     = "thameezbo"
}

variable "project_name" {
  description = "Name of project. This is automatically configured by oneDeploy for prod deployments"
  type        = string
  default     = "ag-ret-eks"
}
