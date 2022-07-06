# Get the ssh key from keyvault, write it into the provision script ready for use in extension

data "azurerm_key_vault" "kv" {
  name                = "SharedKvMsdn1"
  resource_group_name = "SharedServices"
}

data "azurerm_key_vault_secret" "ssh" {
  name         = "id-rsa"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "template_file" "provision" {
  template = file("${path.module}/Powershell/provision.tpl.ps1")
  vars = {
    SshKey = data.azurerm_key_vault_secret.ssh.value
  }
}

resource "local_file" "ssh" {
    content  = data.template_file.provision.rendered
    filename = "provision.ps1"
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