variable "aks_cluster_name" {
  type        = string
  description = "The name of the AKS cluster to create"
}

variable "cluster_location" {
  type        = string
  description = "The Azure region where the AKS cluster will be deployed"
}

variable "dns_prefix" {
  type        = string
  description = "The DNS prefix of the cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version the cluster will use"
}

variable "service_principal_client_id" {
  type        = string
  description = "The Client ID for the service principal associated with the cluster"
}

variable "service_principal_secret" {
  type        = string
  description = "The Client Secret for the service principal associated with the cluster"
}

# The output variables from the networking module as input variables for this module
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the networking resources are located"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network where the cluster will be connected"
}

variable "control_plane_subnet_id" {
  type        = string
  description = "The ID of the subnet for the control plane nodes"
}

variable "worker_node_subnet_id" {
  type        = string
  description = "The ID of the subnet for the worker nodes"
}