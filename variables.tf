variable "AppName" {
  type = string
  description = "App name used in all naming"
}

variable "Location" {
  type = string
  description = "Singular Azure location for the deployment"
}
variable "VmName" {
  type = string
  description = "The Name of the VM to deploy"
}
