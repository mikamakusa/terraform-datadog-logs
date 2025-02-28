variable "archive" {
  type = list(object({
    id = any
    name  = string
    query = string
    include_tags = optional(bool)
    rehydration_max_scan_size_in_gb = optional(number)
    rehydration_tags = optional(list(string))
    azure_archive = optional(list(object({
      client_id       = string
      container       = string
      storage_account = string
      tenant_id       = string
      path = optional(string)
    })), [])
    gcs_archive = optional(list(object({
      bucket       = string
      client_email = string
      path = optional(string)
      project_id = optional(string)
    })), [])
    s3_archive = optional(list(object({
      account_id = string
      bucket     = string
      role_name  = string
      encryption_key = optional(string)
      encryption_type = optional(string)
      path = optional(string)
    })), [])
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Archive API resource, which is used to create and manage Datadog logs archives.
EOT
  validation {
    condition = length([for a in var.archive : true if contains(["NO_OVERRIDE", "SSE_S3", "SSE_KMS"], a.s3_archive.encryption_type)]) == length(var.archive)
    error_message = "Valid values are : NO_OVERRIDE, SSE_S3 or SSE_KMS."
  }
}
variable "archive_order" {
  type = list(object({
    id = any
    archive_id = list(any)
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Archive API resource, which is used to manage Datadog log archives order.
EOT
}
variable "custom_destination" {
  type = list(object({
    id = any
    name = string
    enabled = optional(bool)
    forward_tags = optional(map(string))
    forward_tags_restriction_list = optional(list(string))
    forward_tags_restriction_list_type = optional(string)
    query = optional(string)
    elasticsearch_destination = optional(list(object({
      endpoint = string
      index_name = string
      index_rotation = optional(string)
      basic_auth = optional(list(object({
        password = string
        username = string
      })), [])
    })), [])
    http_destination = optional(list(object({
      endpoint = string
      basic_auth = optional(list(object({
        password = string
        username = string
      })), [])
      custom_header_auth = optional(list(object({
        header_name = string
        header_value = string
      })), [])
    })), [])
    splunk_destination = optional(list(object({
      access_token = string
      endpoint = string
    })), [])
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Custom Destination API resource, which is used to create and manage Datadog log forwarding.
EOT

  validation {
    condition = length([for a in var.custom_destination : true if contains(["ALLOW_LIST", "BLOCK_LIST"], a.forward_tags_restriction_list_type)]) == length(var.custom_destination)
    error_message = "Valid values are : ALLOW_LIST or BLOCK_LIST."
  }
}
variable "custom_pipeline" {
  type = any
}
variable "index" {
  type = any
}
variable "index_order" {
  type = any
}
variable "integration" {
  type = any
}
variable "metric" {
  type = any
}
variable "pipeline_order" {
  type = any
}