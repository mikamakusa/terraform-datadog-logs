output "logs_archive_id" {
  value = try(datadog_logs_archive.archive.*.id)
}

output "archive_order_id" {
  value = try(datadog_logs_archive_order.archive_order.*.id)
}

output "custom_pipeline_id" {
  value = try(datadog_logs_custom_pipeline.custom_pipeline.*.id)
}

output "logs_index_id" {
  value = try(datadog_logs_index.index.*.id)
}

output "index_order_id" {
  value = try(datadog_logs_index_order.index_order.*.id)
}

output "pipeline_order_id" {
  value = try(datadog_logs_pipeline_order.pipeline_order.*.id)
}