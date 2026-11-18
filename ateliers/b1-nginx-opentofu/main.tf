resource "docker_image" "nginx" {
  name         = "nginx:1.28-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = "infra-si-nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
    ip       = "127.0.0.1"
  }
}

output "nginx_url" {
  value = "http://127.0.0.1:8080"
}
