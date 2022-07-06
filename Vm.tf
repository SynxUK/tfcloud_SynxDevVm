
resource "azurerm_public_ip" "ip" {
  name                = "${var.VmName}${lower("${local.VmNameHash}")}Ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label = "${lower("${var.VmName}")}${lower("${local.VmNameHash}")}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.VmName}${lower("${local.VmNameHash}")}Nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}



resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.VmName}${lower("${local.VmNameHash}")}Vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
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

resource "azurerm_virtual_machine_extension" "ext" {
  name                 = "${var.VmName}${lower("${local.VmNameHash}")}Ext"
  #resource_group_name  = azurerm_resource_group.rg.name
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {
     "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("provision.ps1"), "UTF-16LE")}"
  }
  SETTINGS
}

# resource "azurerm_virtual_machine_extension" "ext" {
#   name                 = "${var.VmName}${lower("${local.VmNameHash}")}Ext"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings                   = <<SETTINGS
#     { 
#       "script": 
#         [
#           "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
#           "choco install -y powershell-core git terraform vscode googlechrome"
#         ],
#       "fileUris": []
#     } 
#   SETTINGS
# }

# resource "azurerm_virtual_machine_extension" "ext" {
#   name                       = "${var.VmName}${lower("${local.VmNameHash}")}Ext"
#   location                   = azurerm_windows_virtual_machine.vm.location
#   resource_group_name        = azurerm_windows_virtual_machine.vm.resource_group_name
#   # virtual_machine_name       = azurerm_windows_virtual_machine.vm.name
#   publisher                  = "Microsoft.CPlat.Core"
#   type                       = "RunCommandWindows"
#   type_handler_version       = "1.1"
#   auto_upgrade_minor_version = true

#   settings                   = <<SETTINGS
#     { 
#       "script": 
#         [
#           "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))",
#           "choco install -y powershell-core git terraform vscode googlechrome"
#         ],
#       "fileUris": []
#     } 
#   SETTINGS
# }

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
