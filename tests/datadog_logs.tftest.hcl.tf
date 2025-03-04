run "setup_tests" {
  module {
    source = "./tests/setup"
  }
}

run "log_archive" {
  command = apply
  plan_options = normal

  variables {
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
  }
}