locals {
  images = {
    postgres = "postgres:16-alpine"
    gitea    = "gitea/gitea:1.25"
    jenkins  = "jenkins/jenkins:lts-jdk21"
    sonar    = "sonarqube:community"
  }

  data = {
    postgres = "/var/lib/postgresql/data"
    gitea    = "/data"
    jenkins  = "/var/jenkins_home"
    sonar    = "/opt/sonarqube/data"
    plugins  = "/opt/sonarqube/extensions"
    logs     = "/opt/sonarqube/logs"
  }

  password = "sonar-lab-only"

  web = {
    gitea = {
      port = 3000
      env = [
        "GITEA__server__ROOT_URL=http://localhost:3000/",
        "GITEA__database__DB_TYPE=sqlite3",
        "GITEA__server__DISABLE_SSH=true",
      ]
    }
    jenkins = {
      port = 8080
      env  = []
    }
  }
}

resource "docker_network" "devops" {
  name = "devops-net"
}

resource "docker_image" "service" {
  for_each     = local.images
  name         = each.value
  keep_locally = true
}

resource "docker_volume" "data" {
  for_each = local.data
  name     = "devops-${each.key}"
}

resource "docker_container" "postgres" {
  name  = "devops-postgres"
  image = docker_image.service["postgres"].image_id
  env = [
    "POSTGRES_DB=sonar",
    "POSTGRES_USER=sonar",
    "POSTGRES_PASSWORD=${local.password}",
  ]

  networks_advanced {
    name    = docker_network.devops.name
    aliases = ["postgres"]
  }

  volumes {
    volume_name    = docker_volume.data["postgres"].name
    container_path = local.data.postgres
  }

  ports {
    internal = 5432
    external = 5432
    ip       = "127.0.0.1"
  }

  healthcheck {
    test     = ["CMD", "pg_isready", "-h", "127.0.0.1", "-U", "sonar", "-d", "sonar"]
    interval = "3s"
    timeout  = "2s"
    retries  = 20
  }

  wait         = true
  wait_timeout = 90
}

resource "docker_container" "web" {
  for_each = local.web
  name     = "devops-${each.key}"
  image    = docker_image.service[each.key].image_id
  env      = each.value.env

  networks_advanced {
    name    = docker_network.devops.name
    aliases = [each.key]
  }

  volumes {
    volume_name    = docker_volume.data[each.key].name
    container_path = local.data[each.key]
  }

  ports {
    internal = each.value.port
    external = each.value.port
    ip       = "127.0.0.1"
  }
}

resource "docker_container" "sonar" {
  name  = "devops-sonar"
  image = docker_image.service["sonar"].image_id
  env = [
    "SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonar",
    "SONAR_JDBC_USERNAME=sonar",
    "SONAR_JDBC_PASSWORD=${local.password}",
  ]

  depends_on = [docker_container.postgres]

  networks_advanced {
    name    = docker_network.devops.name
    aliases = ["sonarqube"]
  }

  dynamic "volumes" {
    for_each = toset(["sonar", "plugins", "logs"])
    content {
      volume_name    = docker_volume.data[volumes.value].name
      container_path = local.data[volumes.value]
    }
  }

  ports {
    internal = 9000
    external = 9000
    ip       = "127.0.0.1"
  }

  ulimit {
    name = "nofile"
    soft = 131072
    hard = 131072
  }

  ulimit {
    name = "nproc"
    soft = 8192
    hard = 8192
  }
}

output "gitea_url" {
  value = "http://127.0.0.1:3000"
}

output "jenkins_url" {
  value = "http://127.0.0.1:8080"
}

output "sonarqube_url" {
  value = "http://127.0.0.1:9000"
}