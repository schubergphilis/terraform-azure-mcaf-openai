resource "azurerm_cognitive_account" "openai" {
  # checkov:skip=CKV2_AZURE_22: Customer managed key encryption will be used if provided by user
  name                               = var.name
  custom_subdomain_name              = var.name
  fqdns                              = var.allowed_fqdns
  kind                               = "OpenAI"
  local_auth_enabled                 = false
  location                           = local.openai_location
  outbound_network_access_restricted = true
  public_network_access_enabled      = var.enable_public_access
  resource_group_name                = var.resource_group_name
  sku_name                           = var.sku

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
    ip_rules       = var.enable_public_access ? var.trusted_ips : []
  }
}

resource "azurerm_role_assignment" "cognitive_crypto_access" {
  count = local.encryption_key_id != null ? 1 : 0

  scope                = local.encryption_key_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id
}

resource "azurerm_cognitive_account_customer_managed_key" "oai_cmk" {
  count = local.encryption_key_id != null ? 1 : 0

  cognitive_account_id = azurerm_cognitive_account.openai.id
  key_vault_key_id     = local.encryption_key_id
}

resource "azurerm_private_endpoint" "openaipep" {
  count               = var.create_private_endpoint ? 1 : 0
  name                = "${var.name}-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.subnet_id

  dynamic "ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name               = "${var.name}-pep-ip"
      private_ip_address = var.private_ip_address
      subresource_name   = "account"
      member_name        = "default"
    }
  }

  private_service_connection {
    name                           = "${var.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.create_private_endpoint ? [1] : []
    content {
      name = "default"
      private_dns_zone_ids = var.create_private_dns_zone ? [
        azurerm_private_dns_zone.openaidns[0].id
        ] : [
        var.existing_private_dns_zone_id
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "openaidns" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetopenaidnslink" {
  count                 = var.create_private_dns_zone ? 1 : 0
  name                  = "${var.name}-openaidnslink-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.openaidns[0].name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = local.vnet_id
}

locals {
  log_categories = ["Audit", "AzureOpenAIRequestUsage", "RequestResponse", "Trace"]
}

resource "azurerm_monitor_diagnostic_setting" "openaidiag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diagnostics"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = local.log_categories

    content {
      category = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

resource "azurerm_cognitive_deployment" "models" {
  for_each = var.models

  cognitive_account_id       = azurerm_cognitive_account.openai.id
  dynamic_throttling_enabled = each.value.enable_dynamic_throttling
  name                       = each.key
  rai_policy_name            = azapi_resource.content_filters.name
  version_upgrade_option     = "NoAutoUpgrade"

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = each.value.model.version
  }

  sku {
    capacity = each.value.scale.capacity
    name     = each.value.scale.type
  }
}

resource "azapi_resource" "content_filters" {
  name                      = "${var.name}-content-filter"
  parent_id                 = azurerm_cognitive_account.openai.id
  schema_validation_enabled = false
  type                      = "Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01"

  body = {
    displayName = "${var.name} Content Filter"
    properties = {
      basePolicyName = "Microsoft.Default"
      contentFilters = var.content_filters
      mode           = "Default"
      type           = "UserManaged"
    }
  }
}
