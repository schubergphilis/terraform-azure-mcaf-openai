data "azurerm_key_vault" "kv" {
  count               = var.key_vault_name != null ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name != null ? var.key_vault_resource_group_name : var.resource_group_name
}

data "azurerm_key_vault_key" "encryption_key" {
  count        = var.key_vault_name != null && var.encryption_key_name != null ? 1 : 0
  name         = var.encryption_key_name
  key_vault_id = data.azurerm_key_vault.kv[0].id
}

data "azurerm_subnet" "openai_subnet" {
  count = var.create_private_endpoint && var.subnet_name != null && var.vnet_name != null ? 1 : 0

  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_virtual_network" "openai_vnet" {
  count               = var.create_private_endpoint && var.vnet_name != null ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}
