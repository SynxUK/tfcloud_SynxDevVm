data "azurerm_resource_group" "rg" {
  name = var.AppName
}

data "azurerm_storage_account" "st" {
  name                = "${lower("${var.AppName}")}${lower("${local.AppNameHash}")}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "vnet" {
  name = "${var.AppName}Vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name = "${var.AppName}Subnet"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_network_security_group" "subnetnsg" {
  name                = "${var.AppName}SubnetNsg"
  resource_group_name = data.azurerm_resource_group.rg.name
}