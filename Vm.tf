
resource "azurerm_public_ip" "ip" {
  name                = "${var.AppName}${terraform.workspace}Ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label = "devbox${lower("${terraform.workspace}")}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.AppName}${terraform.workspace}Nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}



resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${terraform.workspace}Vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B4ms"
  admin_username      = "stuart"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


# resource "azurerm_virtual_machine_extension" "dscext" {
#   name                 = var.dsc_config_name
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.83"
#   depends_on           = [azurerm_windows_virtual_machine.vm]

#   settings           = <<SETTINGS_JSON
#         {
#             "configurationArguments": {
#                 "RegistrationUrl": "${data.azurerm_automation_account.ac.endpoint}",
#                 "NodeConfigurationName": "${var.dsc_config_name}.localhost",
#                 "ConfigurationMode": "ApplyAndMonitor",
#                 "ConfigurationModeFrequencyMins": 15,
#                 "RefreshFrequencyMins": 30,
#                 "RebootNodeIfNeeded": false,
#                 "ActionAfterReboot": "continueConfiguration",
#                 "AllowModuleOverwrite": true
#             }
#         }
#     SETTINGS_JSON
#   protected_settings = <<PROTECTED_SETTINGS_JSON
#     {
#         "configurationArguments": {
#             "RegistrationKey": {
#                 "UserName": "PLACEHOLDER_DONOTUSE",
#                 "Password": "${data.azurerm_automation_account.ac.primary_key}"
#             }
#         }
#     }
#   PROTECTED_SETTINGS_JSON
# }
