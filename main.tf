# main.tf file in aks-terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

provider "azurerm" {
  features {}
}



# Call the networking module
module "networking" {
  source = "./networking"

  # Provide the input variables for the networking module
  resource_group_name = "networking-resource-group"
  location            = "UK South"
  vnet_address_space  = ["10.0.0.0/16"]
}



# Call the cluster module
module "cluster" {
  source = "./aks-cluster"

  # Provide the input variables for the cluster module
  aks_cluster_name           = "terraform-aks-cluster"
  cluster_location           = "UK South"
  dns_prefix                 = "myaks-project"
  kubernetes_version         = "1.26.6"
  service_principal_client_id = "var.client_id_value"
  service_principal_secret    = "var.client_secret_value"

  # Use the output variables from the networking module as input variables for the cluster module
  resource_group_name      = module.networking.networking_resource_group_name
  vnet_id                  = module.networking.vnet_id
  control_plane_subnet_id  = module.networking.control_plane_subnet_id
  worker_node_subnet_id    = module.networking.worker_node_subnet_id
  #aks_nsg_id               = module.networking.aks_nsg_id
}