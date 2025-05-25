variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "iperfcdn"
}

variable "locations" {
  description = "The list of AWS regions to deploy resources in"
  type        = set(string)
  default     = ["us-west-1", "ca-central-1", "af-south-1", "ap-east-1", "ap-south-1", "ap-northeast-1", "ap-southeast-2", "eu-central-1", "eu-north-1", "sa-east-1"]
}