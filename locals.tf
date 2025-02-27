locals {
  vnet_id           = var.create_private_endpoint && var.vnet_name != null ? data.azurerm_virtual_network.openai_vnet[0].id : null
  subnet_id         = var.create_private_endpoint && var.subnet_name != null ? data.azurerm_subnet.openai_subnet[0].id : null
  encryption_key_id = var.key_vault_name != null && var.encryption_key_name != null ? data.azurerm_key_vault_key.encryption_key[0].id : null
  openai_location   = var.openai_location != null ? var.openai_location : var.location
}
