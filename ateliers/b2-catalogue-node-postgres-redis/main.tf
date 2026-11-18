resource "docker_network" "catalogue" {
  name = "infra-si-catalogue-net"
}

resource "docker_volume" "postgres" {
  name = "infra-si-catalogue-pg"
}

resource "docker_volume" "redis" {
  name = "infra-si-catalogue-redis"
}

resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

resource "docker_container" "postgres" {
  name  = "infra-si-catalogue-db"
  image = docker_image.postgres.image_id
  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  networks_advanced {
    name    = docker_network.catalogue.name
    aliases = ["db"]
  }

  volumes {
    volume_name     = docker_volume.postgres.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD", "pg_isready", "-h", "127.0.0.1", "-U", var.db_user, "-d", var.db_name]
    interval = "3s"
    timeout  = "2s"
    retries  = 20
  }

  wait          = true
  wait_timeout  = 90
}

resource "docker_container" "redis" {
  name    = "infra-si-catalogue-cache"
  image   = docker_image.redis.image_id
  command = ["redis-server", "--appendonly", "yes"]

  networks_advanced {
    name    = docker_network.catalogue.name
    aliases = ["redis"]
  }

  volumes {
    volume_name     = docker_volume.redis.name
    container_path = "/data"
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "3s"
    timeout  = "2s"
    retries  = 20
  }

  wait         = true
  wait_timeout = 90
}

resource "docker_container" "api" {
  name  = "infra-si-catalogue-api"
  image = var.api_image_id
  env = [
    "DB_HOST=db",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "REDIS_URL=redis://redis:6379"
  ]

  networks_advanced {
    name = docker_network.catalogue.name
  }

  ports {
    internal = 3000
    external = var.api_port
    ip       = "127.0.0.1"
  }

  depends_on = [docker_container.postgres, docker_container.redis]
}

output "api_url" {
  value = "http://127.0.0.1:${var.api_port}"
}
