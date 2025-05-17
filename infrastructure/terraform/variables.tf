variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "iperfcdn"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "locations" {
  description = "The list of Azure regions to deploy resources in"
  type        = set(string)
  default     = ["eastus", "westus", "canadacentral", "brazilsouth", "southafricanorth", "germanywestcentral", "polandcentral", "norwayeast", "uksouth" , "eastasia", "japanwest", "southeastasia", "koreacentral", "centralindia", "qatarcentral", "australiaeast"]
}