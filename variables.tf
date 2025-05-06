variable "location" {
  description = "The location for the Azure OpenAI resources."
  type        = string
}

variable "name" {
  description = "A prefix to be appended to resource names for uniqueness."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "enable_public_access" {
  description = "Optional boolean flag to enable or disable public network access."
  type        = bool
  default     = false
}

variable "trusted_ips" {
  description = "Optional list of trusted IP addresses for network access. Only needed when `enable_public_access` is set to `true`."
  type        = list(string)
  default     = []
}

variable "allowed_fqdns" {
  description = "A list of allowed FQDNs for the Azure OpenAI resource."
  type        = list(string)
  default     = ["openai.azure.com"]
}

variable "sku" {
  description = "The SKU for the Azure OpenAI resource."
  type        = string
  default     = "S0"

  validation {
    condition     = contains(["B1", "B2", "S0", "S1", "S2", "S4", "D1"], var.sku)
    error_message = "Invalid value for sku. Valid options are: B1, B2, S0, S1, S2, S4, D1."
  }
}

variable "models" {
  description = "A map of Azure OpenAI models to be deployed. Each model should specify dynamic throttling, model information, and scale settings."
  type = map(object({
    enable_dynamic_throttling = bool
    model = object({
      name    = string
      version = string
      format  = string
    })
    scale = object({
      type     = string
      capacity = number
    })
  }))
}

variable "content_filters" {
  description = "Optional list of content filters for the OpenAI content policy. If not set, defaults to a pre-defined list."
  type        = list(map(any))
  default = [
    { name = "Violence", blocking = true, enabled = true, severityThreshold = "High", source = "Prompt" },
    { name = "Violence", blocking = true, enabled = true, severityThreshold = "High", source = "Completion" },
    { name = "Hate", blocking = true, enabled = true, severityThreshold = "High", source = "Prompt" },
    { name = "Hate", blocking = true, enabled = true, severityThreshold = "High", source = "Completion" },
    { name = "Sexual", blocking = true, enabled = true, severityThreshold = "High", source = "Prompt" },
    { name = "Sexual", blocking = true, enabled = true, severityThreshold = "High", source = "Completion" },
    { name = "Selfharm", blocking = true, enabled = true, severityThreshold = "High", source = "Prompt" },
    { name = "Selfharm", blocking = true, enabled = true, severityThreshold = "High", source = "Completion" },
    { name = "Jailbreak", blocking = true, enabled = true, source = "Prompt" },
    { name = "Jailbreak", blocking = true, enabled = true, source = "Completion" },
    { name = "Indirect Attack", blocking = true, enabled = true, source = "Prompt" },
    { name = "Indirect Attack", blocking = true, enabled = true, source = "Completion" },
    { name = "Protected Material Text", blocking = true, enabled = true, source = "Prompt" },
    { name = "Protected Material Text", blocking = true, enabled = true, source = "Completion" },
    { name = "Protected Material Code", blocking = true, enabled = true, source = "Prompt" },
    { name = "Protected Material Code", blocking = false, enabled = true, source = "Completion" },
  ]
}

variable "openai_location" {
  description = "Optional Azure location where the OpenAI models should be deployed in different location than the RG. (NOTE: Will be deprecated in future versions)"
  type        = string
  default     = null
}

variable "create_private_endpoint" {
  description = "Optional boolean flag to control whether this module creates a private endpoint. Set to false if you're managing private endpoints outside of this module."
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "The name of the subnet where the private endpoint will be deployed. Only required when create_private_endpoint is true and subnet_id is not provided."
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "The name of the virtual network where the private endpoint will be deployed. Required when create_private_endpoint is true."
  type        = string
  default     = null
}

variable "create_private_dns_zone" {
  description = "Optional boolean flag to control whether this module creates the private DNS zone. Set to false if you're managing DNS zones outside of this module."
  type        = bool
  default     = false
}

variable "existing_private_dns_zone_id" {
  description = "ID of an existing private DNS zone to use. Required when create_private_dns_zone is false and create_private_endpoint is true."
  type        = string
  default     = null
}

variable "private_ip_address" {
  description = "Optional static IP for the private endpoint. Only used when `create_private_endpoint` is true."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  type        = bool
  default     = false
  description = "Whether to enable diagnostic settings for the Azure OpenAI service"
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostics. Required when enable_diagnostics is true."
  type        = string
  default     = null
}

variable "encryption_key_name" {
  description = "Name of the encryption key in the key vault. If not provided, an Azure managed key will be used."
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Name of the key vault containing the encryption key. Only required when encryption_key_name is not provided."
  type        = string
  default     = null
}


variable "key_vault_resource_group_name" {
  description = "Resource group name of the key vault. If not provided, resource_group_name will be used. Only required when encryption_key_name is provided."
  type        = string
  default     = null
}
