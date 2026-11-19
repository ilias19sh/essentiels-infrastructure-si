terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.1"
    }
  }
}

provider "docker" {}

variable "environment_name" {
  type        = string
  description = "Prefix used for resources in the local test environment."
  default     = "websolutions-test"
}

resource "docker_network" "test" {
  name = var.environment_name
}

resource "docker_volume" "postgres" {
  name = "${var.environment_name}-postgres"
}

output "docker_network" {
  value = docker_network.test.name
}

output "postgres_volume" {
  value = docker_volume.postgres.name
}

output "application_url" {
  value = "http://127.0.0.1:8080"
}