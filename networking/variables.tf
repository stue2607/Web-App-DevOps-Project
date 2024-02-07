variable "resource_group_name" {
  type    = string
  default = "networking_resource_group"
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}