archive = [
  {
    id    = 0
    name  = "my s3 archive"
    query = "service:myservice"
    s3_archive = [
      {
        bucket     = "my-bucket"
        path       = "/path/foo"
        account_id = "001234567888"
        role_name  = "my-role-name"
      }
    ]
  }
]