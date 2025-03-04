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
  type = list(object({
    id = any
    name = string
    description = optional(string)
    is_enabled = optional(bool)
    tags = optional(list(string))
    filter = optional(list(object({
      query = string
    })), [])
    processor = optional(list(object({
      arithmetic_processor = optional(list(object({
        expression = string
        target     = string
        is_enabled = bool
        is_replace_missing = optional(bool)
        name = optional(string)
      })))
      attribute_remapper = optional(list(object({
        source_type = string
        sources = optional(list(string))
        target      = optional(string)
        target_type = optional(string)
        is_enabled = optional(bool)
        name = optional(string)
        override_on_conflict = optional(bool)
        preserve_source = optional(bool)
        target_format = optional(string)
      })))
      category_processor = optional(list(object({
        target = string
        is_enabled = optional(bool)
        name = optional(string)
        category = optional(list(object({
          name = string
          filter = optional(list(object({
            query = string
          })), [])
        })), [])
      })))
      date_remapper = optional(list(object({
        sources = optional(list(string))
        is_enabled = optional(bool)
        name = optional(string)
      })))
      geo_ip_parser = optional(list(object({
        sources = optional(list(string))
        target = optional(string)
        is_enabled = optional(bool)
        name = optional(string)
      })))
      grok_parser = optional(list(object({
        source = optional(string)
        name = optional(string)
        is_enabled = optional(bool)
        samples = optional(list(string))
        grok = optional(list(object({
          match_rules   = string
          support_rules = string
        })), [])
      })))
      lookup_processor = optional(list(object({
        lookup_table = optional(list(string))
        source = optional(string)
        target = optional(string)
        default_lookup = optional(string)
        is_enabled = optional(bool)
        name = optional(string)
      })))
      message_remapper = optional(list(object({
        sources = optional(list(string))
        is_enabled  = optional(bool)
        name = optional(string)
      })))
      pipeline = optional(list(object({
        name = optional(string)
        description = optional(string)
        is_enabled = optional(bool)
        tags = optional(list(string))
        filter = optional(list(object({
          query = string
        })), [])
      })), [])
      reference_table_lookup_processor = optional(list(object({
        lookup_enrichment_table = string
        source                  = string
        target                  = string
        is_enabled = optional(bool)
        name = optional(string)
      })))
      service_remapper = optional(list(object({
        sources = optional(list(string))
        is_enabled  = optional(bool)
        name = optional(string)
      })))
      status_remapper = optional(list(object({
        sources = optional(list(string))
        is_enabled  = optional(bool)
        name = optional(string)
      })))
      string_builder_processor = optional(list(object({
        target   = string
        template = string
        is_enabled = optional(bool)
        is_replace_missing = optional(bool)
        name = optional(string)
      })))
      trace_id_remapper = optional(list(object({
        sources = optional(list(string))
        is_enabled  = optional(bool)
        name = optional(string)
      })))
      url_parser = optional(list(object({
        sources = optional(list(string))
        target = optional(string)
        is_enabled  = optional(bool)
        normalize_ending_slashes = optional(bool)
        name = optional(string)
      })))
      user_agent_parser = optional(list(object({
        sources = optional(list(string))
        target = optional(string)
        is_enabled = optional(bool)
        is_encoded = optional(bool)
        name = optional(string)
      })))
    })), [])
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Pipeline API resource, which is used to create and manage Datadog logs custom pipelines. Each datadog_logs_custom_pipeline resource defines a complete pipeline. The order of the pipelines is maintained in a different resource: datadog_logs_pipeline_order. When creating a new pipeline, you need to explicitly add this pipeline to the datadog_logs_pipeline_order resource to track the pipeline. Similarly, when a pipeline needs to be destroyed, remove its references from the datadog_logs_pipeline_order resource.
EOT

  validation {
    condition = length([for a in var.custom_pipeline : true if contains(["attribute", "tag"], a.processor.attribute_remapper.target_type)]) == length(var.custom_pipeline)
    error_message = "Valid values are 'attributes' or 'tag'."
  }

  validation {
    condition = length([for b in var.custom_pipeline : true if contains(["string", "integer", "double"], b.processor.attribute_remapper.target_format)]) == length(var.custom_pipeline)
    error_message = "Valid values are : 'string', 'integer' or 'double'."
  }
}

variable "index" {
  type = list(object({
    id = any
    name = string
    daily_limit = optional(number)
    daily_limit_warning_threshold_percentage = optional(number)
    disable_daily_limit = optional(bool)
    flex_retention_days = optional(number)
    retention_days = optional(number)
    filter = list(object({
      query = string
    }))
    daily_limit_reset = optional(list(object({
      reset_time       = string
      reset_utc_offset = string
    })), [])
    exclusion_filter = optional(list(object({
      is_enabled = optional(bool)
      name = optional(string)
      query = optional(list(object({
        query = optional(string)
        sample_rate = optional(number)
      })) ,[])
    })), [])
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Index API resource. This can be used to create and manage Datadog logs indexes.
Note: It is not possible to delete logs indexes through Terraform, so an index remains in your account after the resource is removed from your terraform config. Reach out to support to delete a logs index.
EOT
}

variable "index_order" {
  type = list(object({
    id = any
    index_id = any
    name = optional(string)
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Index API resource. This can be used to manage the order of Datadog logs indexes.
EOT
}

variable "integration" {
  type = list(object({
    id = any
    is_enabled = optional(bool)
  }))
  default = []
}

variable "metric" {
  type = list(object({
    id = any
    name = string
    compute = list(object({
      aggregation_type = string
      include_percentiles = optional(bool)
      path = optional(string)
    }))
    filter = list(object({
      query = string
    }))
    group_by = optional(list(object({
      path     = string
      tag_name = string
    })), [])
  }))
  default = []
  description = <<EOT
Resource for interacting with the logs_metric API
EOT

  validation {
    condition = length([for a in var.metric : true if contains(["count", "distribution"], a.compute.aggregation_type)]) == length(var.metric)
    error_message = "Valid values are : 'count' or 'distribution'."
  }
}

variable "pipeline_order" {
  type = list(object({
    id = any
    name = string
    pipeline_id = any
  }))
  default = []
  description = <<EOT
Provides a Datadog Logs Pipeline API resource, which is used to manage Datadog log pipelines order.
EOT
}