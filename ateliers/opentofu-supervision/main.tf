locals {
  services = {
    node = {
      image   = "node:24-alpine"
      port    = 8080
      command = ["node", "/opt/demo/app.js"]
      files   = { "/opt/demo/app.js" = "app.js" }
      data    = { "/logs" = "app_logs" }
    }
    prometheus = {
      image   = "prom/prometheus:v3.16.0"
      port    = 9090
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
      ]
      files = { "/etc/prometheus/prometheus.yml" = "prometheus.yml" }
      data  = { "/prometheus" = "prometheus" }
    }
    grafana = {
      image   = "grafana/grafana:13.3.0"
      port    = 3000
      command = null
      files   = {}
      data    = { "/var/lib/grafana" = "grafana" }
    }
    loki = {
      image   = "grafana/loki:3.7.0"
      port    = 3100
      command = ["-config.file=/etc/loki/lab.yaml"]
      files   = { "/etc/loki/lab.yaml" = "loki.yaml" }
      data    = { "/loki" = "loki" }
    }
    alloy = {
      image   = "grafana/alloy:v1.21.2"
      port    = null
      command = [
        "run",
        "--storage.path=/var/lib/alloy/data",
        "/etc/alloy/config.alloy",
      ]
      files = { "/etc/alloy/config.alloy" = "config.alloy" }
      data = {
        "/logs"                 = "app_logs"
        "/var/lib/alloy/data" = "alloy"
      }
    }
  }
}

resource "docker_network" "monitoring" {
  name = "monitoring-net"
}

resource "docker_image" "service" {
  for_each     = local.services
  name         = each.value.image
  keep_locally = true
}

resource "docker_volume" "data" {
  for_each = toset(["app_logs", "prometheus", "grafana", "loki", "alloy"])
  name     = "monitoring-${each.key}"
}

resource "docker_container" "service" {
  for_each = local.services
  name     = "monitoring-${each.key}"
  image    = docker_image.service[each.key].image_id
  command  = each.value.command

  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = [each.key]
  }

  dynamic "ports" {
    for_each = each.value.port == null ? [] : [each.value.port]
    content {
      internal = ports.value
      external = ports.value
      ip       = "127.0.0.1"
    }
  }

  dynamic "volumes" {
    for_each = each.value.files
    content {
      host_path      = abspath("${path.module}/${volumes.value}")
      container_path = volumes.key
      read_only      = true
    }
  }

  dynamic "volumes" {
    for_each = each.value.data
    content {
      volume_name    = docker_volume.data[volumes.value].name
      container_path = volumes.key
      read_only      = each.key == "alloy" && volumes.key == "/logs"
    }
  }
}

output "application_url" {
  value = "http://127.0.0.1:8080"
}

output "prometheus_url" {
  value = "http://127.0.0.1:9090"
}

output "grafana_url" {
  value = "http://127.0.0.1:3000"
}

output "loki_url" {
  value = "http://127.0.0.1:3100"
}