output "cognitive_account_id" {
  description = "ID of the OpenAI cognitive account."
  value       = azurerm_cognitive_account.openai.id
}

output "cognitive_account_name" {
  description = "Name of the OpenAI cognitive account."
  value       = azurerm_cognitive_account.openai.name
}

output "cognitive_account_endpoint" {
  description = "The endpoint of the Azure OpenAI cognitive account."
  value       = azurerm_cognitive_account.openai.endpoint
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (null if create_private_endpoint is false)."
  value       = var.create_private_endpoint ? azurerm_private_endpoint.openaipep[0].id : null
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone (null if create_private_endpoint is false)."
  value       = var.create_private_endpoint ? azurerm_private_dns_zone.openaidns[0].id : null
}
