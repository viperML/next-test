namespace "default" {
  policy = "deny"

  variables {
    path "nomad/jobs/next-test" {
      capabilities = ["write"]
    }
  }
}
