terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "tcp://192.168.2.177:2375"
}

resource "docker_image" "cloudflared" {
  name         = "cloudflare/cloudflared:latest"
  keep_locally = true
}

resource "docker_image" "nginx_proxy_manager" {
  name         = "jc21/nginx-proxy-manager:latest"
  keep_locally = true
}

resource "docker_image" "postgres" {
  name         = "postgres:latest"
  keep_locally = false
}

resource "docker_volume" "nginx_proxy_manager_data" {
  name = "nginx-proxy-manager-data"
}

resource "docker_volume" "nginx_proxy_manager_letsencrypt" {
  name = "nginx-proxy-manager-letsencrypt"
}

resource "docker_volume" "postgres" {
  name = "postgres"
}

resource "docker_container" "cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "cloudflared"

  command = [
    "tunnel",
    "--no-autoupdate",
    "run",
    "--token",
    "eyJhIjoiN2YwYjViYjc3OGNiNWJiNGE1NTMzMGQ5MmMwODExNWEiLCJ0IjoiYTZmNTFhOTgtN2RmOS00NDA2LWIxM2UtZWFkNzJiMmMzZGFjIiwicyI6IlpEQTVaR0kyWVdRdE56bGlOaTAwTkRjMExUZ3lNekF0WkdObE9HUmtaR0kzWkdJdyJ9"
  ]

  restart = "unless-stopped"

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "nginx_proxy_manager" {
  image = docker_image.nginx_proxy_manager.image_id
  name  = "nginx-proxy-manager"

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 81
    external = 81
  }

  ports {
    internal = 443
    external = 443
  }

  volumes {
    volume_name    = docker_volume.nginx_proxy_manager_data.name
    container_path = "/data"
  }

  volumes {
    volume_name    = docker_volume.nginx_proxy_manager_letsencrypt.name
    container_path = "/etc/letsencrypt"
  }

  restart = "unless-stopped"

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres"

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_DB=postgres",
  ]

  volumes {
    volume_name    = docker_volume.postgres.name
    container_path = "/var/lib/postgresql/data"
  }

  restart = "unless-stopped"

  ports {
    internal = 5432
    external = 15432
  }

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}
