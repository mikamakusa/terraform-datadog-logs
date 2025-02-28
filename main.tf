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
  name = ""
  description = ""
  is_enabled = true
  tags = []

  dynamic "filter" {
    for_each = ""
    content {
      query = ""
    }
  }

  dynamic "processor" {
    for_each = ""
    content {
      arithmetic_processor {
        expression = ""
        target     = ""
        is_enabled = true
        is_replace_missing = true
        name = ""
      }
      attribute_remapper {
        source_type = ""
        sources = []
        target      = ""
        target_type = ""
        is_enabled = true
        name = ""
        override_on_conflict = true
        preserve_source = true
        target_format = ""
      }
      category_processor {
        target = ""
        is_enabled = true
        name = ""
        category {
          name = ""
          filter {
            query = ""
          }
        }
      }
      date_remapper {
        sources = []
        is_enabled = true
        name = ""
      }
      geo_ip_parser {
        sources = []
        target = ""
        is_enabled = true
        name = ""
      }
      grok_parser {
        source = ""
        name = ""
        is_enabled = true
        samples = []
        grok {
          match_rules   = ""
          support_rules = ""
        }
      }
      lookup_processor {
        lookup_table = []
        source = ""
        target = ""
        default_lookup = ""
        is_enabled = true
        name = ""
      }
      message_remapper {
        sources = []
        is_enabled  = true
        name = ""
      }
      pipeline {
        name = ""
        description = ""
        is_enabled = true
        tags = []
        filter {
          query = ""
        }
      }
      reference_table_lookup_processor {
        lookup_enrichment_table = ""
        source                  = ""
        target                  = ""
        is_enabled = true
        name = ""
      }
      service_remapper {
        sources = []
        is_enabled  = true
        name = ""
      }
      status_remapper {
        sources = []
        is_enabled  = true
        name = ""
      }
      string_builder_processor {
        target   = ""
        template = ""
        is_enabled = true
        is_replace_missing = true
        name = ""
      }
      trace_id_remapper {
        sources = []
        is_enabled  = true
        name = ""
      }
      url_parser {
        sources = []
        target = ""
        is_enabled  = true
        normalize_ending_slashes = true
        name = ""
      }
      user_agent_parser {
        sources = []
        target = ""
        is_enabled = true
        is_encoded = true
        name = ""
      }
    }
  }
}

resource "datadog_logs_index" "index" {
  name = ""
}

resource "datadog_logs_index_order" "index_order" {
  indexes = []
}

resource "datadog_logs_integration" "integration" {}

resource "datadog_logs_metric" "metric" {
  name = ""
}

resource "datadog_logs_pipeline_order" "pipeline_order" {
  name = ""
  pipelines = []
}