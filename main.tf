terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.19.0"  # Ensuring compatibility with the installed version
    }
  }
}

provider "azurerm" {
  features {}  # This is required

  subscription_id = "7e7e9b8c-d389-4d54-ae57-03a451e26d57"
  tenant_id       = "3d5f800c-9cff-41c4-867a-b1a332a9ff4d"
  client_id       = "74fe0e0b-c9a8-4e63-affa-16b8b416236f"
  #client_secret   = "6d76c140-1ecb-40d3-b380-ec2ce9b9822d"
  client_secret   = "FMF8Q~b2zoHQO06~twjcLNobbZMIEt_rYVCvqb4z"
  #FMF8Q~b2zoHQO06~twjcLNobbZMIEt_rYVCvqb4z "secret value"
}
data "azurerm_virtual_network" "spoke_vnet" {
  name                = var.dmz_spoke_vnet_name
  resource_group_name = var.vnet_rg
}

# resource "azurerm_route" "dmz_route" {
#   count                   = length(data.azurerm_virtual_network.spoke_vnet.address_space)
#   name                    = "${var.dmz_spoke_vnet_name}-ROUTE-${count.index + 1}"
#   resource_group_name     = var.vnet_rg
#   route_table_name        = "hihi"
#   address_prefix          = data.azurerm_virtual_network.spoke_vnet.address_space[count.index]
#   next_hop_type           = "VirtualAppliance"
#   next_hop_in_ip_address  = "10.0.0.4" 
# }
resource "azurerm_route" "dmz-route" {
  for_each = {
    for i, cidr in try(data.azurerm_virtual_network.spoke_vnet.address_space, []) : i => cidr
  }

  name                   = "${var.dmz_spoke_vnet_name}-ROUTE-${each.key + 1}"
  resource_group_name    = var.vnet_rg
  route_table_name       = "hihi"
  address_prefix         = data.azurerm_virtual_network.spoke_vnet.address_space[each.key]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.0.4"
}
