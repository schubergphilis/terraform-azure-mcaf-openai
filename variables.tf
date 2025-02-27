variable "location" {
  description = "The location for the Azure OpenAI resources."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The location for the resource group. This can be different from the Azure OpenAI location."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint will be deployed. Only required when `create_private_endpoint` is true."
  type        = string
}

variable "private_ip_address" {
  description = "Optional static IP for the private endpoint. Only used when `create_private_endpoint` is true."
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "The ID of the virtual network where the private endpoint will be deployed. Only required when `create_private_endpoint` is true."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostics."
  type        = string
}

variable "trusted_ips" {
  description = "Optional list of trusted IP addresses for network access. Only needed when `enable_public_access` is set to `true`."
  type        = list(string)
  default     = []
}

variable "enable_public_access" {
  description = "Optional boolean flag to enable or disable public network access."
  type        = bool
  default     = false
}

variable "name" {
  description = "A prefix to be appended to resource names for uniqueness."
  type        = string
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

variable "encryption_key_id" {
  description = "Optional key vault key ID to use for encryption. If not provided, the module will use a managed encryption key."
  type        = string
  default     = null
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

variable "create_private_endpoint" {
  description = "Optional boolean flag to control whether this module creates a private endpoint. Set to false if you're managing private endpoints outside of this module."
  type        = bool
  default     = true
}
