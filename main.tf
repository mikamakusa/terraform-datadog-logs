resource "datadog_logs_archive" "archive" {
  count = length(var.archive)
  name  = lookup(var.archive[count.index], "name")
  query = lookup(var.archive[count.index], "query")
  include_tags = lookup(var.archive[count.index], "include_tags")
  rehydration_max_scan_size_in_gb = lookup(var.archive[count.index], "rehydration_max_scan_size_in_gb")
  rehydration_tags = lookup(var.archive[count.index], "rehydration_tags")

  dynamic "azure_archive" {
    for_each = try(lookup(var.archive[count.index], "azure_archive")) == null ? [] : ["azure_archive"]
    content {
      client_id       = lookup(azure_archive.value, "client_id")
      container       = lookup(azure_archive.value, "container")
      storage_account = lookup(azure_archive.value, "storage_account")
      tenant_id       = lookup(azure_archive.value, "tenant_id")
      path = lookup(azure_archive.value, "path")
    }
  }

  dynamic "gcs_archive" {
    for_each = try(lookup(var.archive[count.index], "gcs_archive")) == null ? [] : ["gcs_archive"]
    content {
      bucket       = lookup(gcs_archive.value, "bucket")
      client_email = lookup(gcs_archive.value, "client_email")
      path = lookup(gcs_archive.value, "path")
      project_id = lookup(gcs_archive.value, "project_id")
    }
  }

  dynamic "s3_archive" {
    for_each = try(lookup(var.archive[count.index], "s3_archive")) == null ? [] : ["s3_archive"]
    content {
      account_id = lookup(s3_archive.value, "account_id")
      bucket     = lookup(s3_archive.value, "bucket")
      role_name  = lookup(s3_archive.value, "role_name")
      encryption_key = lookup(s3_archive.value, "encryption_key")
      encryption_type = lookup(s3_archive.value, "encryption_type", "NO_OVERRIDE")
      path = lookup(s3_archive.value, "path")
    }
  }
}

resource "datadog_logs_archive_order" "archive_order" {
  count = length(var.archive_order)
  archive_ids = element(datadog_logs_archive.archive.*.id, lookup(var.archive_order[count.index], "archive_id"))
}

resource "datadog_logs_custom_destination" "custom_destination" {
  count = length(var.custom_destination)
  name = lookup(var.custom_destination[count.index], "name")
  enabled = lookup(var.custom_destination[count.index], "enabled")
  forward_tags = lookup(var.custom_destination[count.index], "forward_tags")
  forward_tags_restriction_list = lookup(var.custom_destination[count.index], "forward_tags_restriction_list")
  forward_tags_restriction_list_type = lookup(var.custom_destination[count.index], "forward_tags_restriction_list_type")
  query = lookup(var.custom_destination[count.index], "query")

  dynamic "elasticsearch_destination" {
    for_each = try(lookup(var.custom_destination[count.index], "elasticsearch_destination") == null ? [] : ["elasticsearch_destination"])
    iterator = elasticsearch
    content {
      endpoint = lookup(elasticsearch.value, "endpoint")
      index_name = lookup(elasticsearch.value, "index_name")
      index_rotation = lookup(elasticsearch.value, "index_rotation")

      dynamic "basic_auth" {
        for_each = try(lookup(elasticsearch.value, "basic_auth") == null ? [] : ["basic_auth"])
        content {
          password = sensitive(lookup(basic_auth.value, "password"))
          username = sensitive(lookup(basic_auth.value, "username"))
        }
      }
    }
  }

  dynamic "http_destination" {
    for_each = try(lookup(var.custom_destination[count.index], "http_destination") == null ? [] : ["http_destination"])
    iterator = http
    content {
      endpoint = lookup(http.value, "endpoint")

      dynamic "basic_auth" {
        for_each = try(lookup(http.value, "basic_auth") == null ? [] : ["basic_auth"])
        content {
          password = sensitive(lookup(basic_auth.value, "password"))
          username = sensitive(lookup(basic_auth.value, "username"))
        }
      }

      dynamic "custom_header_auth" {
        for_each = try(lookup(http.value, "custom_header_auth") == null ? [] : ["custom_header_auth"])
        content {
          header_name = lookup(custom_header_auth.value, "header_name")
          header_value = lookup(custom_header_auth.value, "header_value")
        }
      }
    }
  }

  dynamic "splunk_destination" {
    for_each = try(lookup(var.custom_destination[count.index], "splunk_destination") == null ? [] : ["splunk_destination"])
    iterator = splunk
    content {
      access_token = sensitive(lookup(splunk.value, "access_token"))
      endpoint = lookup(splunk.value, "endpoint")
    }
  }
}

resource "datadog_logs_custom_pipeline" "custom_pipeline" {
  count = length(var.custom_pipeline)
  name = lookup(var.custom_pipeline[count.index], "name")
  description = lookup(var.custom_pipeline[count.index], "description")
  is_enabled = lookup(var.custom_pipeline[count.index], "is_enabled")
  tags = lookup(var.custom_pipeline[count.index], "tags")

  dynamic "filter" {
    for_each = try(lookup(var.custom_pipeline[count.index], "filter") == null ? [] : ["filter"])
    content {
      query = lookup(filter.value, "query")
    }
  }

  dynamic "processor" {
    for_each = try(lookup(var.custom_pipeline[count.index], "processor") == null ? [] : ["processor"])
    content {
      dynamic "arithmetic_processor" {
        for_each = try(lookup(processor.value, "arithmetic_processor") == null ? [] : ["arithmetic_processor"])
        iterator = arithmetic
        content {
          expression = lookup(arithmetic.value, "expression")
          target     = lookup(arithmetic.value, "target")
          is_enabled = lookup(arithmetic.value, "is_enabled")
          is_replace_missing = lookup(arithmetic.value, "is_replace_missing")
          name = lookup(arithmetic.value, "name")
        }
      }

      dynamic "attribute_remapper" {
        for_each = try(lookup(processor.value, "attribute_remapper") == null ? [] : ["attribute_remapper"])
        iterator = attribute
        content {
          source_type = lookup(attribute.value, "source_type")
          sources = lookup(attribute.value, "sources")
          target      = lookup(attribute.value, "target")
          target_type = lookup(attribute.value, "target_type")
          is_enabled = lookup(attribute.value, "is_enabled")
          name = lookup(attribute.value, "name")
          override_on_conflict = lookup(attribute.value, "override_on_conflict")
          preserve_source = lookup(attribute.value, "preserve_source")
          target_format = lookup(attribute.value, "target_format")
        }
      }

      dynamic "category_processor" {
        for_each = try(lookup(processor.value, "category_processor") == null ? [] : ["category_processor"])
        iterator = category
        content {
          target = lookup(category.value, "target")
          is_enabled = lookup(category.value, "is_enabled")
          name = lookup(category.value, "name")

          dynamic "category" {
            for_each = try(lookup(category.value, "category") == null ? [] : ["category"])
            content {
              name = lookup(category.value, "name")

              dynamic "filter" {
                for_each = lookup(category.value, "filter")
                content {
                  query = lookup(filter.value, "query")
                }
              }
            }
          }
        }
      }
      dynamic "date_remapper" {
        for_each = try(lookup(processor.value, "date_remapper") == null ? [] : ["date_remapper"])
        iterator = date
        content {
          sources = lookup(date.value, "sources")
          is_enabled = lookup(date.value, "is_enabled")
          name = lookup(date.value, "name")
        }
      }

      dynamic "geo_ip_parser" {
        for_each = try(lookup(processor.value, "geo_ip_parser") == null ? [] : ["geo_ip_parser"])
        iterator = geo_ip
        content {
          sources = lookup(geo_ip.value, "sources")
          target = lookup(geo_ip.value, "target")
          is_enabled = lookup(geo_ip.value, "is_enabled")
          name = lookup(geo_ip.value, "name")
        }
      }

      dynamic "grok_parser" {
        for_each = try(lookup(processor.value, "grok_parser") == null ? [] : ["grok_parser"])
        iterator = grok_parser
        content {
          source = lookup(grok_parser.value, "source")
          name = lookup(grok_parser.value, "name")
          is_enabled = lookup(grok_parser.value, "is_enabled")
          samples = lookup(grok_parser.value, "samples")

          dynamic "grok" {
            for_each = try(lookup(grok_parser.value, "grok") == null ? [] : ["grok"])
            content {
              match_rules   = lookup(grok.value, "match_rules")
              support_rules = lookup(grok.value, "support_rules")
            }
          }
        }
      }

      dynamic "lookup_processor" {
        for_each = try(lookup(processor.value, "lookup_processor") == null ? [] : ["lookup_processor"])
        iterator = lookup_processor
        content {
          lookup_table = lookup(lookup_processor.value, "lookup_table")
          source = lookup(lookup_processor.value, "source")
          target = lookup(lookup_processor.value, "target")
          default_lookup = lookup(lookup_processor.value, "default_lookup")
          is_enabled = lookup(lookup_processor.value, "is_enabled")
          name = lookup(lookup_processor.value, "name")
        }
      }

      dynamic "message_remapper" {
        for_each = try(lookup(processor.value, "message_remapper") == null ? [] : ["message_remapper"])
        iterator = message_remapper
        content {
          sources = lookup(message_remapper.value, "sources")
          is_enabled  = lookup(message_remapper.value, "is_enabled")
          name = lookup(message_remapper.value, "name")
        }
      }

      dynamic "pipeline" {
        for_each = try(lookup(processor.value, "pipeline") == null ? [] : ["pipeline"])
        iterator = pipeline
        content {
          name = lookup(pipeline.value, "name")
          description = lookup(pipeline.value, "description")
          is_enabled = lookup(pipeline.value, "is_enabled")
          tags = lookup(pipeline.value, "tags")

          dynamic "filter" {
            for_each = try(lookup(pipeline.value, "filter") == null ? [] : ["filter"])
            content {
              query = lookup(filter.value, "query")
            }
          }
        }
      }

      dynamic "reference_table_lookup_processor" {
        for_each = try(lookup(processor.value, "reference_table_lookup_processor") == null ? [] : ["reference_table_lookup_processor"])
        iterator = reference_table_lookup_processor
        content {
          lookup_enrichment_table = lookup(reference_table_lookup_processor.value, "lookup_enrichment_table")
          source                  = lookup(reference_table_lookup_processor.value, "source")
          target                  = lookup(reference_table_lookup_processor.value, "target")
          is_enabled = lookup(reference_table_lookup_processor.value, "is_enabled")
          name = lookup(reference_table_lookup_processor.value, "name")
        }
      }

      dynamic "service_remapper" {
        for_each = try(lookup(processor.value, "service_remapper") == null ? [] : ["service_remapper"])
        iterator = service_remapper
        content {
          sources = lookup(service_remapper.value, "sources")
          is_enabled  = lookup(service_remapper.value, "is_enabled")
          name = lookup(service_remapper.value, "name")
        }
      }

      dynamic "status_remapper" {
        for_each = try(lookup(processor.value, "status_remapper") == null ? [] : ["status_remapper"])
        iterator = status_remapper
        content {
          sources = lookup(status_remapper.value, "sources")
          is_enabled  = lookup(status_remapper.value, "is_enabled")
          name = lookup(status_remapper.value, "name")
        }
      }

      dynamic "string_builder_processor" {
        for_each = try(lookup(processor.value, "string_builder_processor") == null ? [] : ["string_builder_processor"])
        iterator = string_builder_processor
        content {
          target   = lookup(string_builder_processor.value, "target")
          template = lookup(string_builder_processor.value, "template")
          is_enabled = lookup(string_builder_processor.value, "is_enabled")
          is_replace_missing = lookup(string_builder_processor.value, "is_replace_missing")
          name = lookup(string_builder_processor.value, "name")
        }
      }

      dynamic "trace_id_remapper" {
        for_each = try(lookup(processor.value, "trace_id_remapper") == null ? [] : ["trace_id_remapper"])
        iterator = trace_id_remapper
        content {
          sources = lookup(trace_id_remapper.value, "sources")
          is_enabled  = lookup(trace_id_remapper.value, "is_enabled")
          name = lookup(trace_id_remapper.value, "name")
        }
      }

      dynamic "url_parser" {
        for_each = try(lookup(processor.value, "url_parser") == null ? [] : ["url_parser"])
        iterator = url_parser
        content {
          sources = lookup(url_parser.value, "sources")
          target = lookup(url_parser.value, "target")
          is_enabled  = lookup(url_parser.value, "is_enabled")
          normalize_ending_slashes = lookup(url_parser.value, "normalize_ending_slashes")
          name = lookup(url_parser.value, "name")
        }
      }

      dynamic "user_agent_parser" {
        for_each = try(lookup(processor.value, "user_agent_parser") == null ? [] : ["user_agent_parser"])
        iterator = user_agent_parser
        content {
          sources = lookup(user_agent_parser.value, "sources")
          target = lookup(user_agent_parser.value, "target")
          is_enabled = lookup(user_agent_parser.value, "is_enabled")
          is_encoded = lookup(user_agent_parser.value, "is_encoded")
          name = lookup(user_agent_parser.value, "name")
        }
      }
    }
  }
}

resource "datadog_logs_index" "index" {
  count = length(var.index)
  name = lookup(var.index[count.index], "name")
  daily_limit = lookup(var.index[count.index], "daily_limit")
  daily_limit_warning_threshold_percentage = lookup(var.index[count.index], "daily_limit_warning_threshold_percentage")
  disable_daily_limit = lookup(var.index[count.index], "disable_daily_limit")
  flex_retention_days = lookup(var.index[count.index], "flex_retention_days")
  retention_days = lookup(var.index[count.index], "retention_days")

  dynamic "filter" {
    for_each = try(lookup(var.index[count.index], "filter") == null ? [] : ["filter"])
    content {
      query = lookup(filter.value, "query")
    }
  }

  dynamic "daily_limit_reset" {
    for_each = try(lookup(var.index[count.index], "daily_limit_reset") == null ? [] : ["daily_limit_reset"])
    content {
      reset_time       = lookup(daily_limit_reset.value, "reset_time")
      reset_utc_offset = lookup(daily_limit_reset.value, "reset_utc_offset")
    }
  }

  dynamic "exclusion_filter" {
    for_each = try(lookup(var.index[count.index], "exclusion_filter") == null ? [] : ["exclusion_filter"])
    content {
      is_enabled = lookup(exclusion_filter.value, "is_enabled")
      name = lookup(exclusion_filter.value, "name")

      dynamic "filter" {
        for_each = try(lookup(exclusion_filter.value, "filter") == null ? [] : ["filter"])
        content {
          query = lookup(filter.value, "query")
          sample_rate = lookup(filter.value, "sample_rate")
        }
      }
    }
  }
}

resource "datadog_logs_index_order" "index_order" {
  count = length(var.index_order)
  indexes = [try(element(datadog_logs_index.index.*.id, lookup(var.index_order[count.index], "index_id")))]
  name = lookup(var.index_order[count.index], "name")
}

resource "datadog_logs_integration" "integration" {
  count = length(var.integration)
  is_enabled = lookup(var.integration[count.index], "is_enabled")
}

resource "datadog_logs_metric" "metric" {
  count = length(var.metric)
  name = lookup(var.metric[count.index], "name")

  dynamic "compute" {
    for_each = lookup(var.metric[count.index], "compute")
    content {
      aggregation_type = lookup(compute.value, "aggregation_type")
      include_percentiles = tr(lookup(compute.value, "include_percentiles"))
      path = try(lookup(compute.value, "path"))
    }
  }

  dynamic "filter" {
    for_each = lookup(var.metric[count.index], "filter")
    content {
      query = lookup(filter.value, "query")
    }
  }

  dynamic "group_by" {
    for_each = try(lookup(var.metric[count.index], "group_by") == null ? [] : ["group_by"])
    content {
      path     = lookup(group_by.value, "path")
      tag_name = lookup(group_by.value, "tag_name")
    }
  }
}

resource "datadog_logs_pipeline_order" "pipeline_order" {
  count = length(var.pipeline_order)
  name = lookup(var.pipeline_order[count.index], "name")
  pipelines = try(
    element(datadog_logs_custom_pipeline.custom_pipeline.*.id, lookup(var.pipeline_order[count.index], "pipelineçid"))
  )
}