
job "next-test" {
  datacenters = ["dc1"]

  group "group" {
    network {
      port "http" {
        to = 8080
      }
    }

    task "main" {
      driver = "docker"

      config {
        image = "ghcr.io/viperml/next-test:zxmjfqvl2nhb7gkpg7phyp9anaq607ga"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 64
      }

      service {
        tags     = ["shiva"]
        provider = "consul"
        port     = "http"

        meta {
          location = "/next-test"
        }

        check {
          type     = "http"
          interval = "30s"
          timeout  = "1s"
          path = "/next-test"
        }
      }
    }
  }
}
