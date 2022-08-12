variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "East US"
}
variable "username"{
  description = "the username to enter to the system."
  default     = "cgrs27"
}
variable "password" {
  description = "the pasword for the username."
  default     = "Carlos1978_"
}
variable "rg" {
    description = "the name of the resource group"
    default     = "udacity-rg"
}
variable "image_id" {
  description = "the id of the image source"
  default     = "/subscriptions/1e4e092c-b55e-45ea-8cc8-4e0ef3f7f19c/resourceGroups/udacity-rg/providers/Microsoft.Compute/images/myPackerImage"
}
variable "n_instances" {
  description = "the number of instances"
  default     = 3
}
    