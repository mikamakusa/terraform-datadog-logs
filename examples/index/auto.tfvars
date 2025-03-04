index = [
  {
    id                                       = 0
    name                                     = "your index"
    daily_limit                              = 200000
    daily_limit_warning_threshold_percentage = 50
    retention_days                           = 7
    flex_retention_days                      = 180
    daily_limit_reset = [
      {
        reset_time       = "14:00"
        reset_utc_offset = "+02:00"
      }
    ]
    filter = [
      {
        query = "*"
      }
    ]
    exclusion_filter = [
      {
        name       = "Filter coredns logs"
        is_enabled = true
        filter = [
          {
          query = "app:coredns"
          sample_rate = 0.97
          }
        ]
      }
    ]
  }
]