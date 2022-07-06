output "rg" {
  value = azurerm_public_ip.ip.fqdn
}

output "debugscript" {
  value = data.template_file.provision
}